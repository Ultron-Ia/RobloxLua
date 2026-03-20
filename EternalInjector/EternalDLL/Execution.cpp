#include <Windows.h>
#include <string>
#include <iostream>
#include <vector>
#include "Luau/Luau.hpp"

// Forward declaration
void ExecuteScript(std::string script);

void StartPipeServer()
{
    HANDLE hPipe;
    char buffer[1024 * 10]; // 10KB buffer for scripts
    DWORD dwRead;

    while (true)
    {
        hPipe = CreateNamedPipeA(
            "\\\\.\\pipe\\EternalPipe",
            PIPE_ACCESS_DUPLEX,
            PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT,
            1,
            1024 * 10,
            1024 * 10,
            0,
            NULL
        );

        if (hPipe == INVALID_HANDLE_VALUE) {
            std::cout << "Failed to create pipe." << std::endl;
            Sleep(1000);
            continue;
        }

        std::cout << "[+] Pipe Server waiting for connection..." << std::endl;

        if (ConnectNamedPipe(hPipe, NULL) != FALSE)
        {
            std::string script = "";
            while (ReadFile(hPipe, buffer, sizeof(buffer) - 1, &dwRead, NULL) != FALSE)
            {
                buffer[dwRead] = '\0';
                script += buffer;
            }
            
            if (!script.empty()) {
                ExecuteScript(script);
            }
        }

        DisconnectNamedPipe(hPipe);
        CloseHandle(hPipe);
    }
}

void ExecuteScript(std::string script)
{
    std::cout << "[+] Script Received! Executing..." << std::endl;
    
    // Call our Luau Core to handle the execution
    rbx::Execution::execute(script);
}
