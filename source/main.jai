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

    load_gltf_file("assets/models/Fox/Fox.gltf", *state.renderer);

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

load_gltf_file :: (path: string, renderer: *Renderer.Renderer) {
    gltf_model: TG.Model;

    {
        options:     TG.Parse_Options;
        error_stack: TG.Error_Stack;
        defer TG.error_stack_free(*error_stack);

        TG.parse_options_init(*options);
        TG.error_stack_init(*error_stack);
        error_code := TG.parse_file(*gltf_model, *error_stack, path.data, xx path.count, *options);
        assert(error_code == .OK, "Failed to parse GLTF file at % (%)", path, error_code);
    }

    image_ids: [..]u32;
    {
        String :: #import "String";
        #import "stb_image";

        gltf_root_path := String.path_decomp(path);

        loaded_images: [..]Renderer.Image;
        loaded_images.allocator = temp;
        for 0 .. gltf_model.images_count - 1 {
            image: Renderer.Image = ---;

            image_path := tprint("%%", gltf_root_path, string.{ gltf_model.images[it].uri.len, gltf_model.images[it].uri.data });

            width, height: s32;
            DESIRED_CHANNEL_COUNT :: 4;
            image.data = stbi_load(temp_c_string(image_path), *width, *height, null, DESIRED_CHANNEL_COUNT);
            assert(image.data != null, "Failed to load image from %", image_path);

            image.width         = xx width;
            image.height        = xx height;
            image.channel_count = DESIRED_CHANNEL_COUNT;

            array_add(*loaded_images, image);
        }
        defer for image: loaded_images {
            stbi_image_free(image.data);
        }

        image_ids = Renderer.upload_images(renderer, loaded_images);
    }

    sampler_ids: [..]u32;
    {
        samplers_params: [..]Renderer.Create_Sampler_Params;
        samplers_params.allocator = temp;
        array_resize(*samplers_params, gltf_model.samplers_count);

        for 0 .. gltf_model.samplers_count - 1 {
            gltf_sampler := gltf_model.samplers[it];

            params: Renderer.Create_Sampler_Params = {
                address_mode_w = .REPEAT,
                compare_enable = xx false,
                min_lod        = 0,
            };

            if gltf_sampler.wrap_s == {
                case -1; #through;
                case xx TG.Texture_Wrap.REPEAT;
                    params.address_mode_u = .REPEAT;
                case xx TG.Texture_Wrap.CLAMP_TO_EDGE;
                    params.address_mode_u = .CLAMP_TO_EDGE;
                case xx TG.Texture_Wrap.MIRRORED_REPEAT;
                    params.address_mode_u = .MIRRORED_REPEAT;
            }

            if gltf_sampler.wrap_t == {
                case -1; #through;
                case xx TG.Texture_Wrap.REPEAT;
                    params.address_mode_v = .REPEAT;
                case xx TG.Texture_Wrap.CLAMP_TO_EDGE;
                    params.address_mode_v = .CLAMP_TO_EDGE;
                case xx TG.Texture_Wrap.MIRRORED_REPEAT;
                    params.address_mode_u = .MIRRORED_REPEAT;
            }

            if gltf_sampler.mag_filter == {
                case -1;                                          #through;
                case xx TG.Texture_Filter.LINEAR;                 #through;
                case xx TG.Texture_Filter.LINEAR_MIPMAP_LINEAR;   #through;
                case xx TG.Texture_Filter.LINEAR_MIPMAP_NEAREST;
                    params.mag_filter  = .LINEAR;
                case xx TG.Texture_Filter.NEAREST;                #through;
                case xx TG.Texture_Filter.NEAREST_MIPMAP_NEAREST; #through;
                case xx TG.Texture_Filter.NEAREST_MIPMAP_LINEAR;
                    params.mag_filter  = .NEAREST;
            }

            if gltf_sampler.min_filter == {
                case -1;
                    params.min_filter  = .LINEAR;
                    params.mipmap_mode = .LINEAR;
                    params.max_lod     = 1000; // aka LOD_CLAMP_NONE
                case xx TG.Texture_Filter.LINEAR;
                    params.min_filter  = .LINEAR;
                    params.mipmap_mode = .NEAREST;
                    params.max_lod     = 0.25;
                case xx TG.Texture_Filter.LINEAR_MIPMAP_LINEAR;
                    params.min_filter  = .LINEAR;
                    params.mipmap_mode = .LINEAR;
                    params.max_lod     = 1000; // aka LOD_CLAMP_NONE
                case xx TG.Texture_Filter.LINEAR_MIPMAP_NEAREST;
                    params.min_filter  = .LINEAR;
                    params.mipmap_mode = .NEAREST;
                    params.max_lod     = 1000; // aka LOD_CLAMP_NONE
                case xx TG.Texture_Filter.NEAREST;
                    params.min_filter  = .NEAREST;
                    params.mipmap_mode = .NEAREST;
                    params.max_lod     = 0.25;
                case xx TG.Texture_Filter.NEAREST_MIPMAP_NEAREST;
                    params.min_filter  = .NEAREST;
                    params.mipmap_mode = .NEAREST;
                    params.max_lod     = 1000; // aka LOD_CLAMP_NONE
                case xx TG.Texture_Filter.NEAREST_MIPMAP_LINEAR;
                    params.min_filter  = .NEAREST;
                    params.mipmap_mode = .LINEAR;
                    params.max_lod     = 1000; // aka LOD_CLAMP_NONE
            }

            array_add(
                *samplers_params,
            );
        }

        sampler_ids = Renderer.create_samplers(renderer, samplers_params);
    }

    // @Todo
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
