#include <Windows.h>
#include <string>
#include <iostream>
#include <vector>
#include "Luau/Luau.hpp"

namespace rbx {
    namespace Execution {

        // Internal helper
        void _InternalExecute(std::string script)
        {
            std::cout << "[+] Script Received! Executing..." << std::endl;
            
            // Call our Luau Core to handle the execution
            rbx::Execution::execute(script);
        }

        void StartPipeServer()
        {
            HANDLE hPipe;
            char buffer[1024 * 10];
            DWORD dwRead;

            // Security descriptor to allow everyone access (NULL DACL)
            SECURITY_DESCRIPTOR sd;
            InitializeSecurityDescriptor(&sd, SECURITY_DESCRIPTOR_REVISION);
            SetSecurityDescriptorDacl(&sd, TRUE, NULL, FALSE);
            SECURITY_ATTRIBUTES sa = { sizeof(sa), &sd, FALSE };

            while (true)
            {
                hPipe = CreateNamedPipeA(
                    "\\\\.\\pipe\\EternalPipe",
                    PIPE_ACCESS_DUPLEX,
                    PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT,
                    PIPE_UNLIMITED_INSTANCES,
                    1024 * 10,
                    1024 * 10,
                    0,
                    &sa // Use security attributes
                );

                if (hPipe == INVALID_HANDLE_VALUE) {
                    Sleep(1000);
                    continue;
                }

                if (ConnectNamedPipe(hPipe, NULL) != FALSE)
                {
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

                DisconnectNamedPipe(hPipe);
                CloseHandle(hPipe);
            }
        }
    }
}
