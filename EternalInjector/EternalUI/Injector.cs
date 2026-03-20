using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

namespace EternalUI
{
    public static class Injector
    {
        // P/Invoke for WinAPI
        [DllImport("kernel32.dll")]
        public static extern IntPtr OpenProcess(int dwDesiredAccess, bool bInheritHandle, int dwProcessId);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        public static extern IntPtr GetModuleHandle(string lpModuleName);

        [DllImport("kernel32", CharSet = CharSet.Ansi, ExactSpelling = true, SetLastError = true)]
        static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

        [DllImport("kernel32.dll", SetLastError = true, ExactSpelling = true)]
        static extern IntPtr VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out IntPtr lpNumberOfBytesWritten);

        [DllImport("kernel32.dll")]
        static extern IntPtr CreateRemoteThread(IntPtr hProcess, IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);

        // Access flags
        const int PROCESS_ALL_ACCESS = 0x1F0FFF;
        const uint MEM_COMMIT = 0x1000;
        const uint MEM_RESERVE = 0x2000;
        const uint PAGE_READWRITE = 0x40;

        public static string LastError = "";

        public static bool Inject(string dllPath)
        {
            try
            {
                Process[] processes = Process.GetProcessesByName("RobloxPlayerBeta");
                if (processes.Length == 0)
                {
                    LastError = "RobloxPlayerBeta.exe não encontrado.";
                    return false;
                }

                Process roblox = processes[0];
                IntPtr hProcess = OpenProcess(PROCESS_ALL_ACCESS, false, roblox.Id);
                if (hProcess == IntPtr.Zero)
                {
                    LastError = "Falha ao abrir o processo (Tente rodar como Administrador).";
                    return false;
                }

                IntPtr loadLibAddr = GetProcAddress(GetModuleHandle("kernel32.dll"), "LoadLibraryA");
                if (loadLibAddr == IntPtr.Zero)
                {
                    LastError = "Falha ao obter endereço do LoadLibraryA.";
                    return false;
                }

                byte[] dllBytes = Encoding.Default.GetBytes(dllPath);
                uint size = (uint)dllBytes.Length + 1;

                IntPtr allocMem = VirtualAllocEx(hProcess, IntPtr.Zero, size, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
                if (allocMem == IntPtr.Zero)
                {
                    LastError = "Falha ao alocar memória no processo.";
                    return false;
                }

                IntPtr bytesWritten;
                if (!WriteProcessMemory(hProcess, allocMem, dllBytes, size, out bytesWritten))
                {
                    LastError = "Falha ao escrever caminho da DLL na memória.";
                    return false;
                }

                IntPtr hThread = CreateRemoteThread(hProcess, IntPtr.Zero, 0, loadLibAddr, allocMem, 0, IntPtr.Zero);
                if (hThread == IntPtr.Zero)
                {
                    LastError = "Falha ao criar thread remoto (Bypass de Anti-Cheat necessário?).";
                    return false;
                }

                // Verify if it actually loaded (Wait 1s for initialization)
                System.Threading.Thread.Sleep(1000);
                roblox.Refresh(); // Important to get updated module list
                bool isLoaded = false;
                foreach (ProcessModule module in roblox.Modules)
                {
                    if (module.ModuleName.Equals("EternalDLL.dll", StringComparison.OrdinalIgnoreCase))
                    {
                        isLoaded = true;
                        break;
                    }
                }

                if (!isLoaded)
                {
                    LastError = "DLL solicitada mas NÃO carregada (Verifique se é x64 ou faltam redistribuíveis C++).";
                    return false;
                }

                LastError = "Injeção realizada com sucesso!";
                return true;
            }
            catch (Exception ex)
            {
                LastError = "Erro: " + ex.Message;
                return false;
            }
        }
    }
}
