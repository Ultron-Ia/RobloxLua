#include "Luau.hpp"
#include "offsets.hpp"
#include <iostream>
#include <vector>

namespace rbx {
    // Helper to get module base
    uintptr_t get_base() {
        return reinterpret_cast<uintptr_t>(GetModuleHandleA(NULL));
    }

    void Execution::execute(const char* script) {
        lua_State L = TaskScheduler::get_main_state();
        if (!L) {
            std::cout << "[-] Error: Could not find lua_State. Is the game running?" << std::endl;
            return;
        }

        std::cout << "[+] Found lua_State at: " << L << std::endl;
        
        // In a real execution engine, you would:
        // 1. Compile script to bytecode
        // 2. Call the internal 'luau_load' or 'r_luaL_loadstring' using an offset
        // 3. Call 'r_lua_pcall'
        
        std::cout << "[+] Script execution triggered (requires function addresses)." << std::endl;
    }

    lua_State TaskScheduler::get_main_state() {
        uintptr_t base = get_base();
        
        // 1. Get TaskScheduler
        uintptr_t scheduler = *reinterpret_cast<uintptr_t*>(base + offsets::TaskSchedulerPointer);
        if (!scheduler) return nullptr;

        // 2. Iterate Jobs (Simplified logic)
        // Usually: scheduler + 0x138 (JobStart) to 0x140 (JobEnd)
        uintptr_t jobs_start = *reinterpret_cast<uintptr_t*>(scheduler + 0x138); 
        uintptr_t jobs_end = *reinterpret_cast<uintptr_t*>(scheduler + 0x140);

        for (uintptr_t job = jobs_start; job < jobs_end; job += 0x10) {
            uintptr_t inst = *reinterpret_cast<uintptr_t*>(job);
            std::string name = *reinterpret_cast<const char**>(inst + offsets::Job_Name);
            
            if (name == "ScriptContext") {
                // 3. Get lua_State from ScriptContext
                // Usually ScriptContext + 0x1A8 or similar (check offsets provided)
                uintptr_t sc = inst; 
                lua_State L = *reinterpret_cast<lua_State*>(sc + 0x1A8); // Standard ScriptContext -> State offset
                return L;
            }
        }

        return nullptr;
    }
}
