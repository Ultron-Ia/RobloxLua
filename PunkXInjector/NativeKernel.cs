using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Win32;

namespace PunkXInjector
{
    public static class NativeKernel
    {
        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern uint RtlAdjustPrivilege(int privilege, bool enable, bool client, out bool wasEnabled);

        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern uint NtLoadDriver(ref UNICODE_STRING driverServiceName);

        [DllImport("ntdll.dll", SetLastError = true)]
        public static extern uint NtUnloadDriver(ref UNICODE_STRING driverServiceName);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern IntPtr CreateFile(string lpFileName, uint dwDesiredAccess, uint dwShareMode,
            IntPtr lpSecurityAttributes, uint dwCreationDisposition, uint dwFlagsAndAttributes, IntPtr hTemplateFile);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool DeviceIoControl(IntPtr hDevice, uint dwIoControlCode,
            ref INJECTION_REQUEST lpInBuffer, uint nInBufferSize,
            IntPtr lpOutBuffer, uint nOutBufferSize, out uint lpBytesReturned, IntPtr lpOverlapped);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool CloseHandle(IntPtr handle);

        [StructLayout(LayoutKind.Sequential, Pack = 1, CharSet = CharSet.Unicode)]
        public struct INJECTION_REQUEST
        {
            public uint TargetPid;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
            public string DllPath;
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
        private const uint IOCTL_INJECT_DLL = 2236420; // 0x801
        private const string DRIVER_LINK = "\\\\.\\ModernInjector";

        public static bool Inject(string dllPath, uint processId, out string error)
        {
            error = "";
            string driverName = "ModernInjector";
            string tempDir = Path.GetTempPath();
            string driverPath = Path.Combine(tempDir, driverName + ".sys");

            try
            {
                // 1. Extract modern_injector.sys if present in UI folder instead of embedded
                string localSys = Path.Combine(Application.StartupPath, "modern_injector.sys");
                if (File.Exists(localSys))
                {
                    try { File.Copy(localSys, driverPath, true); } catch { }
                }
                else
                {
                    // Fallback to existing embedded driver just in case
                    try { File.WriteAllBytes(driverPath, DriverData.KernelDriver); } catch { }
                }

                // 2. Adjust privileges
                bool wasEnabled;
                RtlAdjustPrivilege(SE_LOAD_DRIVER_PRIVILEGE, true, false, out wasEnabled);

                // 3. Register in registry
                string regPath = $"System\\CurrentControlSet\\Services\\{driverName}";
                using (var key = Registry.LocalMachine.CreateSubKey(regPath))
                {
                    key!.SetValue("ImagePath", $"\\??\\{driverPath}");
                    key.SetValue("Type", 1);
                }

                // 4. Load driver
                UNICODE_STRING serviceStr = new UNICODE_STRING();
                RtlInitUnicodeString(ref serviceStr, $"\\Registry\\Machine\\{regPath}");
                uint status = NtLoadDriver(ref serviceStr);

                // STATUS_IMAGE_ALREADY_LOADED is acceptable
                if (status != 0 && status != 0xC0000035)
                {
                    error = $"Driver load failed (0x{status:X})";
                    Marshal.FreeHGlobal(serviceStr.Buffer);
                    return false;
                }

                // 5. Open cybryk driver device
                IntPtr hDriver = CreateFile(DRIVER_LINK, 0xC0000000, 0, IntPtr.Zero, 3, 0, IntPtr.Zero);
                if (hDriver == (IntPtr)(-1))
                {
                    error = "Failed to connect to ModernInjector kernel link. Is the .sys loaded?";
                    Marshal.FreeHGlobal(serviceStr.Buffer);
                    return false;
                }

                // 6. Send IOCTL with Cybryk struct (TargetPid + DLL Path string)
                INJECTION_REQUEST data = new INJECTION_REQUEST
                {
                    TargetPid = processId,
                    DllPath = dllPath
                };

                uint bytesRet;
                bool success = DeviceIoControl(hDriver, IOCTL_INJECT_DLL, ref data,
                    (uint)Marshal.SizeOf(data), IntPtr.Zero, 0, out bytesRet, IntPtr.Zero);

                CloseHandle(hDriver);
                Marshal.FreeHGlobal(serviceStr.Buffer);

                if (success)
                {
                    error = "Kernel injection successful.";
                    return true;
                }
                else
                {
                    error = $"IOCTL error: {Marshal.GetLastWin32Error()}";
                    return false;
                }
            }
            catch (Exception ex)
            {
                error = "Kernel exception: " + ex.Message;
                return false;
            }
        }

        public static bool Unload(out string error)
        {
            error = "";
            string driverName = "ModernInjector";
            string regPath = $"System\\CurrentControlSet\\Services\\{driverName}";

            try
            {
                bool wasEnabled;
                RtlAdjustPrivilege(SE_LOAD_DRIVER_PRIVILEGE, true, false, out wasEnabled);

                UNICODE_STRING serviceStr = new UNICODE_STRING();
                RtlInitUnicodeString(ref serviceStr, $"\\Registry\\Machine\\{regPath}");
                uint status = NtUnloadDriver(ref serviceStr);
                Marshal.FreeHGlobal(serviceStr.Buffer);

                try { Registry.LocalMachine.DeleteSubKeyTree(regPath, false); } catch { }

                if (status == 0)
                {
                    error = "Driver unloaded successfully.";
                    return true;
                }
                else
                {
                    error = $"Unload failed (0x{status:X})";
                    return false;
                }
            }
            catch (Exception ex)
            {
                error = "Unload exception: " + ex.Message;
                return false;
            }
        }
    }
}
