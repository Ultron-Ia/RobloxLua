#include <Windows.h>
#include <iostream>
#include <thread>

// Forward declaration from Execution.cpp
extern void StartPipeServer();

void MainThread()
{
    // Initialize Console for Debugging
    AllocConsole();
    FILE* f;
    freopen_s(&f, "CONOUT$", "w", stdout);
    freopen_s(&f, "CONIN$", "r", stdin);

    std::cout << "--- ETERNAL DLL LOADED ---" << std::endl;
    std::cout << "Initializing Pipe Server..." << std::endl;

    // Start Pipe Server in a separate thread
    std::thread(StartPipeServer).detach();

    std::cout << "Ready for execution commands." << std::endl;

    while (true)
    {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        CreateThread(0, 0, (LPTHREAD_START_ROUTINE)MainThread, 0, 0, 0);
        break;
    }
    return TRUE;
}
