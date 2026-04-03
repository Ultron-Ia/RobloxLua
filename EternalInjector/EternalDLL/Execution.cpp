#include <Windows.h>
#include <string>
#include <iostream>
#include <vector>
#include <sddl.h>
#include "Luau/Luau.hpp"

namespace rbx {
    namespace Execution {

        // SEH-safe wrapper (Zero objects with destructors allowed here)
        void _SafeExecute(const char* script)
        {
            __try {
                rbx::Execution::execute(script);
            }
            __except (EXCEPTION_EXECUTE_HANDLER) {
                OutputDebugStringA("[ETERNAL] CRITICAL ERROR: Crashed during Luau execution (likely bad offsets).");
            }
        }

        // Internal helper
        void _InternalExecute(std::string script)
        {
            OutputDebugStringA("[ETERNAL] Script Received! Triggering execution...");
            _SafeExecute(script.c_str());
        }

        void KernelLog(const char* msg) {
            OutputDebugStringA(msg);
        }

        void StartPipeServer()
        {
            HANDLE hPipe;
            char buffer[1024 * 10];
            DWORD dwRead;

            KernelLog("Starting Pipe Server Loop...");

            // Security descriptor to allow everyone including AppContainer access
            SECURITY_DESCRIPTOR* pSd = nullptr;
            SECURITY_ATTRIBUTES sa;
            sa.nLength = sizeof(sa);
            sa.bInheritHandle = FALSE;

            // D:(A;OICI;GA;;;WD)(A;OICI;GA;;;AC) -> Everyone & All Application Packages have Full Access
            if (ConvertStringSecurityDescriptorToSecurityDescriptorA(
                "D:(A;OICI;GA;;;WD)(A;OICI;GA;;;AC)",
                SDDL_REVISION_1,
                (PVOID*)&pSd,
                NULL))
            {
                sa.lpSecurityDescriptor = pSd;
            }
            else
            {
                // Fallback
                static SECURITY_DESCRIPTOR fallbackSd;
                InitializeSecurityDescriptor(&fallbackSd, SECURITY_DESCRIPTOR_REVISION);
                SetSecurityDescriptorDacl(&fallbackSd, TRUE, NULL, FALSE);
                sa.lpSecurityDescriptor = &fallbackSd;
            }

            while (true)
            {
                hPipe = CreateNamedPipeA(
                    "\\\\.\\pipe\\EternalPipe",
                    PIPE_ACCESS_DUPLEX,
                    PIPE_TYPE_BYTE | PIPE_WAIT,
                    PIPE_UNLIMITED_INSTANCES,
                    1024 * 10,
                    1024 * 10,
                    0,
                    &sa
                );

                if (hPipe == INVALID_HANDLE_VALUE) {
                    DWORD err = GetLastError();
                    char buf[128];
                    sprintf_s(buf, "[ETERNAL] Pipe Create failed: %lu", err);
                    KernelLog(buf);
                    Sleep(1000);
                    continue;
                }

                KernelLog("[ETERNAL] Pipe created. Waiting for client...");

                BOOL connected = ConnectNamedPipe(hPipe, NULL) ? TRUE : (GetLastError() == ERROR_PIPE_CONNECTED);
                if (connected)
                {
                    KernelLog("[ETERNAL] Client connected! Processing script...");
                    std::string script = "";
                    while (ReadFile(hPipe, buffer, sizeof(buffer) - 1, &dwRead, NULL) != FALSE)
                    {
                        buffer[dwRead] = '\0';
                        script += buffer;
                    }
                    
                    if (!script.empty()) {
                        _InternalExecute(script);
                    }
                }
                else {
                     KernelLog("[ETERNAL] Client connection failed.");
                }

                KernelLog("[ETERNAL] Closing pipe instance.");
                DisconnectNamedPipe(hPipe);
                CloseHandle(hPipe);
            }
        }
    }
}
