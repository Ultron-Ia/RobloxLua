#include <Windows.h>
#include <iostream>
#include <thread>
#include <fstream>

#include "Luau/Luau.hpp"

// Simple logger for debugging manual mapping
void KernelLog(const char* msg) {
    std::ofstream f("C:\\Users\\Public\\eternal_kernel.log", std::ios::app);
    if (f.is_open()) {
        f << msg << std::endl;
        f.close();
    }
}

DWORD WINAPI MainThread(LPVOID lpParam) {
    KernelLog("[+] MainThread Started");
    
    // Visual confirmation
    MessageBoxA(NULL, "ETERNAL DLL Carregada com Sucesso!", "ETERNAL", MB_OK | MB_ICONINFORMATION);
    
    // Start pipe
    rbx::Execution::StartPipeServer();
    return 0;
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved)
{
    if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(hModule);
        KernelLog("[+] DllMain DLL_PROCESS_ATTACH");
        
        // Spawn main communication thread using WinAPI (safer for manual mapping)
        HANDLE hThread = CreateThread(NULL, 0, MainThread, hModule, 0, NULL);
        if (hThread) CloseHandle(hThread);
    }
    return TRUE;
}
