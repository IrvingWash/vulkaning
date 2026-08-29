#placeholder DEBUG;

#import "Basic"()(
    MEMORY_DEBUGGER                 = DEBUG,
    TEMP_ALLOCATOR_OVERWRITE_MEMORY = DEBUG,
);

#import "SDL3";

State :: struct {
    is_running: bool;

    window: *SDL_Window;
    width:  s32 = 800;
    height: s32 = 600;
}

main :: () {
    #if DEBUG {
        report_memory_leaks();
    }

    state: State;

    init(*state);

    while state.is_running {
        process_input(*state);
    }
}

init :: (state: *State) {
    state.is_running = true;

    ok := SDL_InitSubSystem(SDL_INIT_VIDEO);
    assert(ok, "Failed to initialize SDL Video Subsystem");

    state.window = SDL_CreateWindow(
        "Vulkaning",
        state.width, state.height,
        xx (SDL_Window_Flags.VULKAN | SDL_Window_Flags.RESIZABLE),
    );
    assert(state.window != null, "Failed to create SDL Window");
}

process_input :: (state: *State) {
    event: SDL_Event;
    while SDL_PollEvent(*event) {
        if event.type == {
            case xx SDL_EventType.QUIT;
                state.is_running = false;
                break;
            case xx SDL_EventType.WINDOW_RESIZED;
                state.width  = event.window.data1;
                state.height = event.window.data2;
                break;
        }
    }
}
