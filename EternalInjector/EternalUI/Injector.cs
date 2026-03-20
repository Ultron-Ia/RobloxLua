using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

namespace EternalUI
{
    public static class Injector
    {
        public static string LastError = "";

        public static bool Inject(string dllPath)
        {
            if (!System.IO.File.Exists(dllPath))
            {
                LastError = "DLL não encontrada: " + dllPath;
                return false;
            }

            // MODO EXCLUSIVO: Kernel Injection (ZhangBing Method)
            string kernelError;
            if (NativeKernel.Inject(dllPath, out kernelError))
            {
                LastError = kernelError;
                return true;
            }

            LastError = "Erro Crítico Kernel: " + kernelError;
            return false;
        }
    }
}
