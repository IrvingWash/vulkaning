#placeholder DEBUG;

#import "Basic"()(
    MEMORY_DEBUGGER                 = DEBUG,
    TEMP_ALLOCATOR_OVERWRITE_MEMORY = DEBUG,
);

SDL :: #import "SDL3";
Renderer :: #import,dir "Renderer"()(
    Window_Type = *SDL.Window,
    DEBUG       = DEBUG
);

TG :: #import "Tiny_GLTF"()(DEBUG = DEBUG);

State :: struct {
    is_running: bool;

    window: *SDL.Window;
    width:  s32 = 800;
    height: s32 = 600;

    renderer: Renderer.Renderer;
}

main :: () {
    #if DEBUG {
        defer report_memory_leaks();
    }

    setup_formatting();

    state: State;

    init(*state);
    defer deinit(*state);

    while state.is_running {
        process_input(*state);

        Renderer.render(*state.renderer);

        reset_temporary_storage();
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

    state.renderer = Renderer.init(state.window, get_sdl_instance_extensions, SDL.vulkan_create_surface, SDL.get_window_size_in_pixels);
}

deinit :: (state: *State) {
    Renderer.deinit(*state.renderer);

    SDL.destroy_window(state.window);
    SDL.quit();

    state.* = {};
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

get_sdl_instance_extensions :: () -> [..]*u8 {
    extensions: [..]*u8;

    count: u32;
    raw_extensions := SDL.vulkan_get_instance_extensions(*count);

    array_resize(*extensions, count);

    for 0 .. count - 1 {
        extensions[it] = raw_extensions[it];
    }

    return extensions;
}

setup_formatting :: () {
    print_style := *context.print_style;

    print_style.default_format_struct.draw_type_name = true;
    print_style.default_format_struct.use_long_form_if_more_than_this_many_members = 0;
    print_style.default_format_struct.use_newlines_if_long_form = true;
}
