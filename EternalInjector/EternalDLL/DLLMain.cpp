#include <Windows.h>
#include <iostream>
#include <thread>

// Forward declaration from Execution.cpp
extern void StartPipeServer();

void MainThread()
{
    // Initialize Console for Debugging
// Forward declaration
namespace rbx {
    namespace Execution {
        void StartPipeServer();
    }
}

void MainThread(HMODULE hModule) {
    // Visual confirmation that injection worked
    MessageBoxA(NULL, "ETERNAL DLL Carregada com Sucesso!", "ETERNAL", MB_OK | MB_ICONINFORMATION);
    
    // Start receiving scripts
    rbx::Execution::StartPipeServer();
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved)
{
    if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(hModule);
        std::thread(MainThread, hModule).detach();
    }
    return TRUE;
}
