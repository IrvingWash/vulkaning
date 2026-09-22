#placeholder DEBUG;

#import "Basic"()(
    MEMORY_DEBUGGER                 = DEBUG,
    TEMP_ALLOCATOR_OVERWRITE_MEMORY = DEBUG,
);

#import "Math";

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
    defer array_free(image_ids);
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
    defer array_free(sampler_ids);
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

    texture_ids: [..]u32;
    texture_ids.allocator = temp;
    for 0 .. gltf_model.textures_count - 1 {
        gltf_texture := gltf_model.textures[it];

        id := Renderer.add_texture(
            renderer,
            {
                image_id   = image_ids[gltf_texture.source],
                sampler_id = sampler_ids[gltf_texture.sampler],
            },
        );

        array_add(*texture_ids, id);
    }

    material_ids: [..]u32;
    material_ids.allocator = temp;
    for 0 .. gltf_model.materials_count - 1 {
        gltf_material := gltf_model.materials[it];

        id := Renderer.add_material(
            renderer,
            {
                base_color = {
                    xx gltf_material.pbr_metallic_roughness.base_color_factor[0],
                    xx gltf_material.pbr_metallic_roughness.base_color_factor[1],
                    xx gltf_material.pbr_metallic_roughness.base_color_factor[2],
                    xx gltf_material.pbr_metallic_roughness.base_color_factor[3],
                },
                texture_id = ifx gltf_material.pbr_metallic_roughness.base_color_texture.index == -1
                    then 0
                    else texture_ids[gltf_material.pbr_metallic_roughness.base_color_texture.index] - 1,
            }
        );

        array_add(*material_ids, id);
    }

    mesh_ids: [..]u32;
    mesh_ids.allocator = temp;
    for gltf_mesh_index: 0 .. gltf_model.meshes_count - 1 {
        gltf_mesh := gltf_model.meshes[gltf_mesh_index];

        mesh: Renderer.Mesh;
        if !gltf_mesh.name.data {
            mesh.name = copy_string({
                gltf_mesh.name.len,
                gltf_mesh.name.data,
            });
        }

        array_resize(*mesh.sub_meshes, gltf_mesh.primitives_count);
        for gltf_primitive_index: 0 .. gltf_mesh.primitives_count - 1 {
            gltf_primitive := gltf_mesh.primitives[gltf_primitive_index];

            mesh.sub_meshes[gltf_primitive_index].material_id = material_ids[gltf_primitive.material];
            mesh.sub_meshes[gltf_primitive_index].vertex_start = xx renderer.vertex_offset;

            for gltf_attribute_index: 0 .. gltf_primitive.attributes_count - 1 {
                gltf_attribute := gltf_primitive.attributes[gltf_attribute_index];

                gltf_accessor := gltf_model.accessors[gltf_attribute.value];

                if string.{gltf_attribute.key.len, gltf_attribute.key.data} == {
                    case "POSITION";
                        assert(gltf_accessor.type == xx TG._Type.VEC3 && gltf_accessor.component_type == xx TG.Component_Type.FLOAT);

                        mesh.sub_meshes[gltf_primitive_index].vertex_count = gltf_accessor.count;

                        gltf_buffer_view := gltf_model.buffer_views[gltf_accessor.buffer_view];
                        gltf_buffer := gltf_model.buffers[gltf_buffer_view.buffer];
                        buffer_offset := gltf_buffer_view.byte_offset + gltf_accessor.byte_offset;
                        stride := ifx gltf_buffer_view.byte_stride != 0
                            then gltf_buffer_view.byte_stride
                            else size_of(Vector3);

                        for gltf_accessor_index: 0 .. gltf_accessor.count - 1 {
                            element_offset := buffer_offset + gltf_accessor_index * stride;
                            data: *float = cast(*float, gltf_buffer.data.data + element_offset);

                            renderer.vertices[renderer.vertex_offset + gltf_accessor_index].position = { data[0], data[1], data[3] };
                        }
                    case "NORMAL";
                        assert(gltf_accessor.type == xx TG._Type.VEC3 && gltf_accessor.component_type == xx TG.Component_Type.FLOAT);

                        gltf_buffer_view := gltf_model.buffer_views[gltf_accessor.buffer_view];
                        gltf_buffer := gltf_model.buffers[gltf_buffer_view.buffer];
                        buffer_offset := gltf_buffer_view.byte_offset + gltf_accessor.byte_offset;
                        stride := ifx gltf_buffer_view.byte_stride != 0
                            then gltf_buffer_view.byte_stride
                            else size_of(Vector3);

                        for gltf_accessor_index: 0 .. gltf_accessor.count - 1 {
                            element_offset := buffer_offset + gltf_accessor_index * stride;
                            data: *float = cast(*float, gltf_buffer.data.data + element_offset);

                            renderer.vertices[renderer.vertex_offset + gltf_accessor_index].normal = { data[0], data[1], data[3] };
                        }
                    case "COLOR_0";
                        assert(gltf_accessor.type == xx TG._Type.VEC3 || gltf_accessor.type == xx TG._Type.VEC4);
                        assert(gltf_accessor.component_type == xx TG.Component_Type.FLOAT);

                        gltf_buffer_view := gltf_model.buffer_views[gltf_accessor.buffer_view];
                        gltf_buffer := gltf_model.buffers[gltf_buffer_view.buffer];
                        buffer_offset := gltf_buffer_view.byte_offset + gltf_accessor.byte_offset;
                        stride := ifx gltf_buffer_view.byte_stride != 0
                            then gltf_buffer_view.byte_stride
                            else size_of(Vector3);

                        for gltf_accessor_index: 0 .. gltf_accessor.count - 1 {
                            element_offset := buffer_offset + gltf_accessor_index * stride;
                            data: *float = cast(*float, gltf_buffer.data.data + element_offset);

                            renderer.vertices[renderer.vertex_offset + gltf_accessor_index].color = { data[0], data[1], data[3] };
                        }
                    case "TEXCOORD_0";
                        assert(gltf_accessor.type == xx TG._Type.VEC2 && gltf_accessor.component_type == xx TG.Component_Type.FLOAT);

                        gltf_buffer_view := gltf_model.buffer_views[gltf_accessor.buffer_view];
                        gltf_buffer := gltf_model.buffers[gltf_buffer_view.buffer];
                        buffer_offset := gltf_buffer_view.byte_offset + gltf_accessor.byte_offset;
                        stride := ifx gltf_buffer_view.byte_stride != 0
                            then gltf_buffer_view.byte_stride
                            else size_of(Vector3);

                        for gltf_accessor_index: 0 .. gltf_accessor.count - 1 {
                            element_offset := buffer_offset + gltf_accessor_index * stride;
                            data: *float = cast(*float, gltf_buffer.data.data + element_offset);

                            renderer.vertices[renderer.vertex_offset + gltf_accessor_index].uv = { data[0], data[1] };
                        }
                }

                renderer.vertex_offset += mesh.sub_meshes[gltf_primitive_index].vertex_count;
            }

            if gltf_primitive.indices != -1 {
                gltf_accessor := gltf_model.accessors[gltf_primitive.indices];
                gltf_buffer_view := gltf_model.buffer_views[gltf_accessor.buffer_view];
                gltf_buffer := gltf_model.buffers[gltf_buffer_view.buffer];

                mesh.sub_meshes[gltf_primitive_index].index_start = renderer.index_offset;
                mesh.sub_meshes[gltf_primitive_index].index_count = gltf_accessor.count;

                if gltf_accessor.component_type == {
                    case xx TG.Component_Type.UNSIGNED_INT;
                        data: *u32 = cast(*u32, gltf_buffer.data.data + gltf_buffer_view.byte_offset + gltf_accessor.byte_offset);
                        memcpy(*renderer.indices[renderer.index_offset], data, xx gltf_accessor.count * size_of(u32));
                    case xx TG.Component_Type.UNSIGNED_SHORT;
                        data: *u16 = cast(*u16, gltf_buffer.data.data + gltf_buffer_view.byte_offset + gltf_accessor.byte_offset);

                        for id: 0 .. gltf_accessor.count - 1 {
                            renderer.indices[renderer.index_offset + id] = cast(u32, data[id]);
                        }
                }

                renderer.index_offset += mesh.sub_meshes[gltf_primitive_index].index_count;
            }

            array_add(*renderer.meshes, mesh);
            array_add(*mesh_ids, xx renderer.meshes.count);
        }
    }
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
