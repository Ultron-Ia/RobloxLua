#include <Windows.h>
#include <iostream>
#include <thread>
#include <string>

#include "Luau/Luau.hpp"

#include <fstream>

void KernelLog(const char* msg) {
    OutputDebugStringA(msg);
    std::ofstream logfile("C:\\Users\\hoff\\AppData\\Local\\Temp\\eternal_log.txt", std::ios_base::app);
    if(logfile.is_open()) {
        logfile << msg << std::endl;
        logfile.close();
    }
}

        DWORD WINAPI MainThread(LPVOID lpParam) {
            Beep(800, 200); // MEDIUM PITCH BEEP - Indicates Thread Start
            KernelLog("[ETERNAL] MainThread Started");
            
            KernelLog("[ETERNAL] Starting Pipe Server...");
            rbx::Execution::StartPipeServer();
            return 0;
        }

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved)
{
    if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(hModule);
        Beep(1000, 200); // HIGH PITCH BEEP - Indicates Base DLL Entry
        KernelLog("[ETERNAL] DLL_PROCESS_ATTACH");
        
        HANDLE hThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)MainThread, NULL, 0, NULL);
        if (hThread) {
            KernelLog("[ETERNAL] CreateThread SUCCESS");
            CloseHandle(hThread);
        } else {
            KernelLog("[ETERNAL] CreateThread FAILED");
            char err[50];
            sprintf_s(err, "[ETERNAL] LastError: %d", GetLastError());
            KernelLog(err);
        }
    }
    return TRUE;
}
