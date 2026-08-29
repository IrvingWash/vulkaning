#placeholder DEBUG;

#import "Basic"()(
    MEMORY_DEBUGGER                 = DEBUG,
    TEMP_ALLOCATOR_OVERWRITE_MEMORY = DEBUG,
);

SDL :: #import "SDL3";

State :: struct {
    is_running: bool;

    window: *SDL.Window;
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

    ok := SDL.init_subsystem(.VIDEO);
    assert(ok, "Failed to initialize SDL Video Subsystem");

    state.window = SDL.create_window(
        "Vulkaning",
        state.width, state.height,
        .VULKAN | .RESIZABLE,
    );
    assert(state.window != null, "Failed to create SDL Window");
}

process_input :: (state: *State) {
    event: SDL.Event;
    while SDL.poll_event(*event) {
        if event.type == {
            case .QUIT;
                state.is_running = false;
                break;
            case .WINDOW_RESIZED;
                state.width  = event.window.data1;
                state.height = event.window.data2;
                break;
        }
    }
}
