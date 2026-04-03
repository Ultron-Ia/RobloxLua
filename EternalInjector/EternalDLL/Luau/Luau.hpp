#pragma once
#include <Windows.h>
#include <string>
#include <vector>

namespace rbx {
    // Custom Lua State type
    typedef void* lua_State;

    // Luau function signatures (Placeholders for actual offsets)
    // These are typically found using an offset dumper.
    typedef int(__cdecl* r_luaL_loadstring)(lua_State L, const char* s);
    typedef int(__cdecl* r_lua_pcall)(lua_State L, int nargs, int nresults, int errfunc);
    typedef lua_State(__cdecl* r_get_state)(void* script_context);

    // TaskScheduler structure
    struct TaskScheduler {
        static void* get_scheduler();
        static lua_State get_main_state();
    };

    // Execution Core
    namespace Execution {
        void execute(const char* script);
        void StartPipeServer(); // Added for DLLMain clarity
    }
}
