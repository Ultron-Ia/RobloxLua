using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Win32;

namespace EternalUI
{
    public static class NativeKernel
    {
        // P/Invoke for Native APIs
        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern uint RtlAdjustPrivilege(int privilege, bool enable, bool client, out bool wasEnabled);

        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern uint NtLoadDriver(ref UNICODE_STRING driverServiceName);

        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern uint NtUnloadDriver(ref UNICODE_STRING driverServiceName);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern IntPtr CreateFile(string lpFileName, uint dwDesiredAccess, uint dwShareMode, IntPtr lpSecurityAttributes, uint dwCreationDisposition, uint dwFlagsAndAttributes, IntPtr hTemplateFile);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool DeviceIoControl(IntPtr hDevice, uint dwIoControlCode, ref DriverInjectionData lpInBuffer, uint nInBufferSize, IntPtr lpOutBuffer, uint nOutBufferSize, out uint lpBytesReturned, IntPtr lpOverlapped);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool CloseHandle(IntPtr handle);

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        public struct DriverInjectionData
        {
            public uint ProcessId;
            public uint Unknown1;
            public uint DataSize;
            public uint Unknown2;
            public IntPtr DataBuffer;
            public uint VerifyCode;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct UNICODE_STRING
        {
            public ushort Length;
            public ushort MaximumLength;
            public IntPtr Buffer;
        }

        public static void RtlInitUnicodeString(ref UNICODE_STRING destinationString, string sourceString)
        {
            byte[] bytes = Encoding.Unicode.GetBytes(sourceString);
            destinationString.Buffer = Marshal.AllocHGlobal(bytes.Length + 2);
            Marshal.Copy(bytes, 0, destinationString.Buffer, bytes.Length);
            Marshal.WriteInt16(destinationString.Buffer, bytes.Length, 0);
            destinationString.Length = (ushort)bytes.Length;
            destinationString.MaximumLength = (ushort)(bytes.Length + 2);
        }

        private const int SE_LOAD_DRIVER_PRIVILEGE = 10;
        private const uint IOCTL_INJECT_DLL = 2236420;
        private const uint VERIFICATION_CODE = 721140700;
        private const string DRIVER_LINK = "\\\\.\\mLnUcWtv9IaZf8LBiMXD";

        public static bool Inject(string dllPath, out string error)
        {
            error = "";
            string driverName = "EternalKernel";
            string tempDir = Path.GetTempPath();
            string driverPath = Path.Combine(tempDir, driverName + ".sys");

            try
            {
                // 1. Extract Driver (Only if not already there or can be overwritten)
                try {
                    File.WriteAllBytes(driverPath, DriverData.KernelDriver);
                } catch (IOException) {
                    // If file is in use, assume it's already loaded or correctly placed
                    if (!File.Exists(driverPath)) throw; 
                }

                // 2. Adjust Privileges
                bool wasEnabled;
                RtlAdjustPrivilege(SE_LOAD_DRIVER_PRIVILEGE, true, false, out wasEnabled);

                // 3. Register Driver in Registry
                string regPath = $"System\\CurrentControlSet\\Services\\{driverName}";
                using (var key = Registry.LocalMachine.CreateSubKey(regPath))
                {
                    key.SetValue("ImagePath", $"\\??\\{driverPath}");
                    key.SetValue("Type", 1); // ServiceTypeKernel
                }

                // 4. Load Driver
                UNICODE_STRING serviceStr = new UNICODE_STRING();
                RtlInitUnicodeString(ref serviceStr, $"\\Registry\\Machine\\{regPath}");
                uint status = NtLoadDriver(ref serviceStr);
                
                // 0xC0000035 = STATUS_IMAGE_ALREADY_LOADED (Acceptable)
                if (status != 0 && status != 0xC0000035)
                {
                    error = $"Falha ao carregar driver (Status: 0x{status:X})";
                    return false;
                }

                // 5. Detection
                var roblox = Process.GetProcessesByName("RobloxPlayerBeta").FirstOrDefault();
                if (roblox == null)
                {
                    error = "Roblox não encontrado.";
                    return false;
                }

                // 6. IOCTL Communication
                IntPtr hDriver = CreateFile(DRIVER_LINK, 0xC0000000, 0, IntPtr.Zero, 3, 0, IntPtr.Zero);
                if (hDriver == (IntPtr)(-1))
                {
                    error = "Falha ao abrir link do driver.";
                    return false;
                }

                byte[] dllBytes = File.ReadAllBytes(dllPath);
                GCHandle pinnedDll = GCHandle.Alloc(dllBytes, GCHandleType.Pinned);

                DriverInjectionData data = new DriverInjectionData
                {
                    ProcessId = (uint)roblox.Id,
                    Unknown1 = 0,
                    DataSize = (uint)dllBytes.Length,
                    Unknown2 = 0,
                    DataBuffer = pinnedDll.AddrOfPinnedObject(),
                    VerifyCode = VERIFICATION_CODE
                };

                uint bytesRet;
                bool success = DeviceIoControl(hDriver, IOCTL_INJECT_DLL, ref data, (uint)Marshal.SizeOf(data), IntPtr.Zero, 0, out bytesRet, IntPtr.Zero);

                pinnedDll.Free();
                
                // IMPORTANT: Close the driver handle so Windows allows manual unloading later
                CloseHandle(hDriver);
                
                Marshal.FreeHGlobal(serviceStr.Buffer);
                
                if (success)
                {
                    error = "Injeção Kernel Nativa realizada! Driver ON.";
                    return true;
                }
                else
                {
                    error = $"Erro IOCTL: {Marshal.GetLastWin32Error()}";
                    return false;
                }
            }
            catch (Exception ex)
            {
                error = "Exceção Kernel: " + ex.Message;
                return false;
            }
        }

        public static bool Unload(out string error)
        {
            error = "";
            string driverName = "EternalKernel";
            string regPath = $"System\\CurrentControlSet\\Services\\{driverName}";
            
            try
            {
                bool wasEnabled;
                RtlAdjustPrivilege(SE_LOAD_DRIVER_PRIVILEGE, true, false, out wasEnabled);
                
                UNICODE_STRING serviceStr = new UNICODE_STRING();
                RtlInitUnicodeString(ref serviceStr, $"\\Registry\\Machine\\{regPath}");
                uint status = NtUnloadDriver(ref serviceStr);
                
                Marshal.FreeHGlobal(serviceStr.Buffer);
                
                try {
                    Registry.LocalMachine.DeleteSubKeyTree(regPath, false);
                } catch {}
                
                if (status == 0)
                {
                    error = "Driver descarregado com sucesso!";
                    return true;
                }
                else
                {
                    error = $"Falha ao descarregar (Status: 0x{status:X}).";
                    return false;
                }
            }
            catch (Exception ex)
            {
                error = "Exceção Unload: " + ex.Message;
                return false;
            }
        }
    }
}
