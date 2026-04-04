using System;
using System.Diagnostics;
using System.Linq;

namespace PunkXInjector
{
    public static class Injector
    {
        public static string LastError = "";

        public static bool Inject(string dllPath, uint processId)
        {
            if (!System.IO.File.Exists(dllPath))
            {
                LastError = "DLL not found: " + dllPath;
                return false;
            }

            string kernelError;
            if (NativeKernel.Inject(dllPath, processId, out kernelError))
            {
                LastError = kernelError;
                return true;
            }

            LastError = "Kernel Error: " + kernelError;
            return false;
        }
    }
}
