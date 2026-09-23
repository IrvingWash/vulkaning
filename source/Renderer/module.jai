#module_parameters()(Window_Type: Type, DEBUG := false);

#load "model.jai";

Additional_Instance_Extensions_Getter :: #type () -> [..]*u8;
Window_Pixel_Size_Getter              :: #type (window: Window_Type) -> width: s32, height: s32;

Surface_Creator :: #type (
    window: Window_Type,
    instance: VK.Instance,
    allocator: *void = null,
) -> ok: bool, VK.Surface_Khr;

Renderer :: struct {
    window:                Window_Type;
    get_window_pixel_size: Window_Pixel_Size_Getter;

    instance:        VK.Instance;
    surface:         VK.Surface_Khr;
    physical_device: VK.Physical_Device;

    graphics_qfi: u32;

    device:    VK.Device;
    graphics_queue: VK.Queue;

    allocator: VMA.Allocator;

    swapchain_info: Swapchain_Info;
    depth_image:     GPU_Image;

    graphics_pipeline_info: Graphics_Pipeline_Info;

    timeline_semaphore: VK.Semaphore;
    frame_resources_list: [MAX_FRAMES_IN_FLIGHT_COUNT]Frame_Resources;

    transient_command_pool: VK.Command_Pool;

    should_recreate_swapchain: bool;
    frame_index:               u64;
    next_signal_value:         u64 = MAX_FRAMES_IN_FLIGHT_COUNT + 1; // I guess this is because we initialize the timeline_semaphore with MAX_FRAMES_IN_FLIGHT_COUNT

    white_pixel_texture: Texture;

    gpu_images: [..]GPU_Image;
    samplers:   [..]VK.Sampler;
    textures:   [..]Texture;
    materials:  [..]Material;

    vertices: [..]Vertex;
    indices:  [..]u32;
    vertex_offset: u64;
    index_offset:  u64;

    meshes: [..]Mesh;

    buffers: [..]GPU_Buffer;
    vertex_buffer_id:   int;
    index_buffer_id:    int;
    material_buffer_id: int;

    global_descriptor_pool:       VK.Descriptor_Pool;
    global_descriptor_set_layout: VK.Descriptor_Set_Layout;
    global_descriptor_set:        VK.Descriptor_Set;

    camera: Camera;

    node_render_stack: [..]struct{ node: *Node; matrix: Matrix4; };

    dirty: bool = true;
}

Create_Sampler_Params :: #type VK.Sampler_Create_Info;

Swapchain_Info :: struct {
    swapchain:   VK.Swapchain_Khr;
    config:      VK.Swapchain_Create_Info_Khr;
    images:      [..]VK.Image;
    image_views: [..]VK.Image_View;

    render_complete_semaphores: [..]VK.Semaphore;
}

Graphics_Pipeline_Info :: struct {
    pipeline: VK.Pipeline;
    layout:   VK.Pipeline_Layout;
}

Frame_Resources :: struct {
    command_pool:             VK.Command_Pool;
    command_buffer:           VK.Command_Buffer;
    image_acquired_semaphore: VK.Semaphore;
    indirect_draw_buffer:     GPU_Buffer;
    indirect_draw_pointer:    *VK.Draw_Indexed_Indirect_Command;
    render_item_buffer:       GPU_Buffer;
    render_item_pointer:      *Render_Item;
}

Frame_Constants :: struct {
    vertex_buffer_address:   u64;
    material_buffer_address: u64;
    render_items_address:    u64;
}

GPU_Image :: struct {
    image:      VK.Image;
    image_view: VK.Image_View;
    allocation: VMA.Allocation;
}

GPU_Buffer :: struct {
    buffer:          VK.Buffer;
    allocation:      VMA.Allocation;
    allocation_info: VMA.Allocation_Info;
    device_address:  u64;
}

Camera :: struct {
    yaw:      float = 1.570796;
    pitch:    float;
    distance: float = 10;
}

Render_Item :: struct {
    wvp:            Matrix4;
    world_matrix:   Matrix4;
    material_index: u32;
}

init :: (
    window:                             Window_Type,
    get_additional_instance_extensions: Additional_Instance_Extensions_Getter,
    create_surface:                     Surface_Creator,
    get_window_pixel_size:              Window_Pixel_Size_Getter,
) -> Renderer {
    renderer: Renderer;

    renderer.window = window;
    renderer.get_window_pixel_size = get_window_pixel_size;

    renderer.instance = create_instance(get_additional_instance_extensions);

    ok:, renderer.surface = create_surface(renderer.window, renderer.instance);
    assert(ok, "Failed to create surface");

    renderer.physical_device = find_physical_device(renderer.instance);

    renderer.graphics_qfi = find_graphics_queue_family_index(renderer.physical_device, renderer.surface);

    renderer.device = create_device(renderer.physical_device, renderer.graphics_qfi);

    renderer.graphics_queue = VK.get_device_queue(renderer.device, renderer.graphics_qfi, 0);

    renderer.allocator = init_vma(renderer.physical_device, renderer.device, renderer.instance);

    renderer.swapchain_info = create_swapchain(
        renderer.physical_device,
        renderer.surface,
        renderer.device,
        renderer.window,
        renderer.get_window_pixel_size,
        should_check_format = true,
    );

    renderer.depth_image = create_depth_image(renderer.device, renderer.swapchain_info.config.image_extent, renderer.allocator);

    renderer.global_descriptor_pool,
        renderer.global_descriptor_set_layout,
        renderer.global_descriptor_set = create_descriptor_sets(renderer.device);

    renderer.graphics_pipeline_info = create_graphics_pipeline(renderer.device, renderer.global_descriptor_set_layout);

    renderer.timeline_semaphore = create_timeline_semaphore(renderer.device);
    renderer.frame_resources_list = create_frame_resources(renderer.device, renderer.graphics_qfi);

    renderer.transient_command_pool = create_transient_command_pool(renderer.device, renderer.graphics_qfi);

    array_add(
        *renderer.gpu_images,
        create_white_pixel_image(
            renderer.graphics_queue,
            renderer.allocator,
            renderer.device,
            renderer.transient_command_pool,
        ),
    );
    renderer.white_pixel_texture.image_id = xx renderer.gpu_images.count;

    array_add(
        *renderer.samplers,
        create_sampler(
            renderer.device,
            {
                mag_filter     = .NEAREST,
                min_filter     = .NEAREST,
                address_mode_u = .REPEAT,
                address_mode_v = .REPEAT,
                address_mode_w = .REPEAT,
                compare_enable = VK.FALSE,
            },
        ),
    );
    renderer.white_pixel_texture.sampler_id = xx renderer.samplers.count;

    array_resize(*renderer.vertices, VERTEX_BUFFER_SIZE / size_of(Vertex));
    array_resize(*renderer.indices, INDEX_BUFFER_SIZE / size_of(u32));

    create_indirect_draw_buffers(renderer.device, renderer.allocator, renderer.frame_resources_list);

    return renderer;
}

deinit :: (renderer: *Renderer) {
    VK.device_wait_idle(renderer.device);

    array_free(renderer.node_render_stack);

    VK.destroy_descriptor_set_layout(renderer.device, renderer.global_descriptor_set_layout);
    VK.destroy_descriptor_pool(renderer.device, renderer.global_descriptor_pool);

    for buffer: renderer.buffers {
        VMA.destroy_buffer(renderer.allocator, buffer.buffer, buffer.allocation);
    }
    array_free(renderer.buffers);

    for *mesh: renderer.meshes {
        destroy_mesh(mesh);
    }
    array_free(renderer.meshes);

    array_free(renderer.indices);
    array_free(renderer.vertices);
    array_free(renderer.materials);
    array_free(renderer.textures);

    for sampler: renderer.samplers {
        VK.destroy_sampler(renderer.device, sampler);
    }
    array_free(renderer.samplers);

    for image: renderer.gpu_images {
        destroy_gpu_image(renderer.device, renderer.allocator, image);
    }
    array_free(renderer.gpu_images);

    VK.destroy_command_pool(renderer.device, renderer.transient_command_pool);

    for *frame_resources: renderer.frame_resources_list {
        destroy_frame_resources(renderer.device, renderer.allocator, frame_resources);
    }

    VK.destroy_semaphore(renderer.device, renderer.timeline_semaphore);

    destroy_graphics_pipeline(renderer.device, *renderer.graphics_pipeline_info);

    destroy_depth_image(renderer.device, renderer.allocator, *renderer.depth_image);

    destroy_swapchain(renderer.device, *renderer.swapchain_info);

    VMA.destroy_allocator(renderer.allocator);

    VK.destroy_surface_khr(renderer.instance, renderer.surface);

    VK.destroy_device(renderer.device);

    VK.destroy_instance(renderer.instance);

    renderer.* = {};
}

add_texture :: (renderer: *Renderer, texture: Texture) -> id: u32 {
    array_add(*renderer.textures, texture);

    return xx renderer.textures.count;
}

add_material :: (renderer: *Renderer, material: Material) -> id: u32 {
    array_add(*renderer.materials, material);

    return xx renderer.materials.count;
}

create_samplers :: (renderer: *Renderer, params_list: []Create_Sampler_Params) -> sampler_ids: [..]u32 {
    sampler_ids: [..]u32;

    for params: params_list {
        sampler := create_sampler(renderer.device, params);

        array_add(*renderer.samplers, sampler);

        array_add(*sampler_ids, xx renderer.samplers.count);
    }

    return sampler_ids;
}

upload_images :: (renderer: *Renderer, images: []Image) -> image_ids: [..]u32 {
    command_buffer := start_transient_command_buffer(renderer.device, renderer.transient_command_pool);

    staging_buffers: [..]GPU_Buffer;
    staging_buffers.allocator = temp;
    defer for buffer: staging_buffers {
        VMA.destroy_buffer(renderer.allocator, buffer.buffer, buffer.allocation);
    }

    gpu_image_ids: [..]u32;
    for image: images {
        gpu_image, buffer := create_gpu_image(renderer.device, renderer.allocator, command_buffer, image);

        array_add(*renderer.gpu_images, gpu_image);
        array_add(*staging_buffers, buffer);
        array_add(*gpu_image_ids, xx renderer.gpu_images.count);
    }

    submit_transient_command_buffer(
        renderer.device,
        renderer.transient_command_pool,
        renderer.graphics_queue,
        command_buffer,
    );

    return gpu_image_ids;
}

start_rendering :: (renderer: *Renderer) {
    if !renderer.dirty {
        return;
    }

    defer renderer.dirty = false;

    { // Upload vertex and index buffers
        vertex_staging_buffer := create_buffer(
            renderer.device, renderer.allocator, .TRANSFER_SRC, VERTEX_BUFFER_SIZE, .AUTO, mappable = true
        );
        defer VMA.destroy_buffer(renderer.allocator, vertex_staging_buffer.buffer, vertex_staging_buffer.allocation);
        map_copy_buffer_data(renderer.allocator, vertex_staging_buffer, 0, renderer.vertices.data, VERTEX_BUFFER_SIZE);

        index_staging_buffer  := create_buffer(
            renderer.device, renderer.allocator, .TRANSFER_SRC, INDEX_BUFFER_SIZE, .AUTO, mappable = true
        );
        defer VMA.destroy_buffer(renderer.allocator, index_staging_buffer.buffer, index_staging_buffer.allocation);
        map_copy_buffer_data(renderer.allocator, index_staging_buffer, 0, renderer.indices.data, INDEX_BUFFER_SIZE);

        vertex_buffer := create_buffer(
            renderer.device,
            renderer.allocator,
            .TRANSFER_DST | .SHADER_DEVICE_ADDRESS,
            VERTEX_BUFFER_SIZE,
            .AUTO,
            mappable = false,
        );
        renderer.vertex_buffer_id = add_buffer(*renderer.buffers, vertex_buffer);

        index_buffer := create_buffer(
            renderer.device,
            renderer.allocator,
            .TRANSFER_DST | .INDEX_BUFFER,
            INDEX_BUFFER_SIZE,
            .AUTO,
            mappable = false,
        );
        renderer.index_buffer_id = add_buffer(*renderer.buffers, index_buffer);

        command_buffer := start_transient_command_buffer(renderer.device, renderer.transient_command_pool);

        vertex_buffer_copy := VK.Buffer_Copy.{
            src_offset = 0,
            dst_offset = 0,
            size       = VERTEX_BUFFER_SIZE,
        };
        index_buffer_copy := VK.Buffer_Copy.{
            src_offset = 0,
            dst_offset = 0,
            size       = INDEX_BUFFER_SIZE,
        };
        VK.cmd_copy_buffer(command_buffer, vertex_staging_buffer.buffer, vertex_buffer.buffer, .[vertex_buffer_copy]);
        VK.cmd_copy_buffer(command_buffer, index_staging_buffer.buffer, index_buffer.buffer, .[index_buffer_copy]);

        submit_transient_command_buffer(renderer.device, renderer.transient_command_pool, renderer.graphics_queue, command_buffer);
    }

    { // Update texture descriptors
        image_descriptors: [..]VK.Descriptor_Image_Info;
        image_descriptors.allocator = temp;

        for texture: renderer.textures {
            array_add(
                *image_descriptors,
                {
                    sampler      = renderer.samplers[texture.sampler_id - 1],
                    image_view   = renderer.gpu_images[texture.image_id - 1].image_view,
                    image_layout = .SHADER_READ_ONLY_OPTIMAL,
                }
            );
        }

        write_descriptor_set := VK.Write_Descriptor_Set.{
            dst_set           = renderer.global_descriptor_set,
            dst_binding       = 0,
            dst_array_element = 0,
            descriptor_count  = xx image_descriptors.count,
            descriptor_type   = .COMBINED_IMAGE_SAMPLER,
            p_image_info        = image_descriptors.data,
        };

        VK.update_descriptor_sets(renderer.device, .[write_descriptor_set], .[]);
    }

    { // Material buffers
        material_data_size := renderer.materials.count * size_of(Material);

        material_buffer := create_buffer(
            renderer.device, renderer.allocator, .STORAGE_BUFFER | .SHADER_DEVICE_ADDRESS, xx material_data_size, .AUTO, mappable = true
        );

        renderer.material_buffer_id = add_buffer(*renderer.buffers, material_buffer);

        map_copy_buffer_data(renderer.allocator, material_buffer, 0, renderer.materials.data, material_data_size);
    }
}

render :: (renderer: *Renderer, nodes: []Node) {
    if renderer.should_recreate_swapchain {
        VK.device_wait_idle(renderer.device);

        destroy_swapchain(renderer.device, *renderer.swapchain_info);
        destroy_depth_image(renderer.device, renderer.allocator, *renderer.depth_image);

        renderer.swapchain_info = create_swapchain(
            renderer.physical_device,
            renderer.surface,
            renderer.device,
            renderer.window,
            renderer.get_window_pixel_size,
        );

        renderer.depth_image = create_depth_image(
            renderer.device,
            renderer.swapchain_info.config.image_extent,
            renderer.allocator,
        );

        renderer.should_recreate_swapchain = false;
    }

    frame_resources_index := renderer.frame_index % MAX_FRAMES_IN_FLIGHT_COUNT;
    renderer.frame_index += 1;

    signal_value := renderer.next_signal_value;
    renderer.next_signal_value += 1;

    // Waiting for a signal of MAX_FRAMES_IN_FLIGHT_COUNT ago
    wait_value := signal_value - MAX_FRAMES_IN_FLIGHT_COUNT;

    wait_info := VK.Semaphore_Wait_Info.{
        semaphore_count = 1,
        p_semaphores    = *renderer.timeline_semaphore,
        p_values        = *wait_value,
    };
    VK.wait_semaphores(renderer.device, *wait_info, U64_MAX);

    frame_resources := *renderer.frame_resources_list[frame_resources_index];

    result := VK.reset_command_pool(renderer.device, frame_resources.command_pool, 0);
    ASSERT_SUCCESS("Reset command pool");

    result =, image_index := VK.acquire_next_image_khr(
        renderer.device,
        renderer.swapchain_info.swapchain,
        U64_MAX,
        frame_resources.image_acquired_semaphore,
        null,
    );

    if result == .ERROR_OUT_OF_DATE_KHR {
        renderer.should_recreate_swapchain = true;
        return;
    } else if result == .SUBOPTIMAL_KHR {
        renderer.should_recreate_swapchain = true;
    } else {
        ASSERT_SUCCESS("Acquire next image");
    }

    camera_position := Vector3.{
        cos(renderer.camera.yaw) * cos(renderer.camera.pitch),
        sin(renderer.camera.pitch),
        sin(renderer.camera.yaw) * cos(renderer.camera.pitch)
    } * renderer.camera.distance;

    aspect_ratio := cast(float, renderer.swapchain_info.config.image_extent.width) / cast(float, renderer.swapchain_info.config.image_extent.height);

    view_transform    := make_look_at_matrix(camera_position, { 0, 0, 0 }, { 0, 1, 0 }, x_is_forward = false);
    projection_matrix := make_projection_matrix(1.308997, aspect_ratio, 0.01, 1000, depth_range_01 = true);
    view_projection_matrix := projection_matrix * view_transform;

    array_reset(*renderer.node_render_stack);
    node_id := 1;
    while node_id {
        node := *nodes[node_id - 1];
        array_add(*renderer.node_render_stack, { node, Matrix4_Identity });
        node_id = node.next_sibling_id;
    }

    draw_index: u32;
    while renderer.node_render_stack.count > 0 {
        node_data := pop(*renderer.node_render_stack);

        world_matrix := node_data.matrix * node_data.node.transform;

        if node_data.node.mesh_id {
            mesh := renderer.meshes[node_data.node.mesh_id - 1];

            for sub_mesh: mesh.sub_meshes {
                frame_resources.indirect_draw_pointer[draw_index] = {
                    index_count    = xx sub_mesh.index_count,
                    instance_count = 1,
                    first_index    = xx sub_mesh.index_start,
                    vertex_offset  = xx sub_mesh.vertex_start,
                    first_instance = draw_index,
                };

                frame_resources.render_item_pointer[draw_index] = {
                    wvp            = transpose(view_projection_matrix * world_matrix),
                    world_matrix   = transpose(world_matrix),
                    material_index = sub_mesh.material_id - 1,
                };

                draw_index += 1;
            }
        }

        child_node_id := node_data.node.first_child_id;

        while child_node_id {
            child_node := *nodes[child_node_id - 1];
            array_add(*renderer.node_render_stack, { child_node, world_matrix });
            child_node_id = child_node.next_sibling_id;
        }
    }

    command_buffer_begin_info := VK.Command_Buffer_Begin_Info.{
        flags = .ONE_TIME_SUBMIT,
    };
    result = VK.begin_command_buffer(frame_resources.command_buffer, *command_buffer_begin_info);
    ASSERT_SUCCESS("Begin command buffer");

    // We need to transition images to the renderable state, because it was in a presentable state previously
    render_layout_barriers := VK.Image_Memory_Barrier_2.[
        {
            src_stage_mask    = .COLOR_ATTACHMENT_OUTPUT,
            src_access_mask   = 0,
            dst_stage_mask    = .COLOR_ATTACHMENT_OUTPUT,
            dst_access_mask   = .COLOR_ATTACHMENT_WRITE,
            old_layout        = .UNDEFINED,
            new_layout        = .COLOR_ATTACHMENT_OPTIMAL,
            image             = renderer.swapchain_info.images[image_index],
            subresource_range = {
                aspect_mask      = .COLOR,
                base_mip_level   = 0,
                level_count      = 1,
                base_array_layer = 0,
                layer_count      = 1,
            },
        },
        {
            src_stage_mask  = .EARLY_FRAGMENT_TESTS,
            src_access_mask = 0,
            dst_stage_mask  = .EARLY_FRAGMENT_TESTS | .LATE_FRAGMENT_TESTS,
            dst_access_mask = .DEPTH_STENCIL_ATTACHMENT_WRITE,
            old_layout      = .UNDEFINED,
            new_layout      = .DEPTH_ATTACHMENT_OPTIMAL,
            image           = renderer.depth_image.image,
            subresource_range = {
                aspect_mask      = .DEPTH,
                base_mip_level   = 0,
                level_count      = 1,
                base_array_layer = 0,
                layer_count      = 1,
            },
        }
    ];

    render_dependency_info := VK.Dependency_Info.{
        image_memory_barrier_count = render_layout_barriers.count,
        p_image_memory_barriers    = render_layout_barriers.data,
    };
    VK.cmd_pipeline_barrier_2(frame_resources.command_buffer, *render_dependency_info);

    color_rendering_attachment_info := VK.Rendering_Attachment_Info.{
        image_view                 = renderer.swapchain_info.image_views[image_index],
        image_layout               = .COLOR_ATTACHMENT_OPTIMAL,
        load_op                    = .CLEAR,
        store_op                   = .STORE,
        clear_value.color._float32 = float.[0.01, 0.01, 0.01, 1],
    };

    depth_rendering_attachment_info := VK.Rendering_Attachment_Info.{
        image_view                      = renderer.depth_image.image_view,
        image_layout                    = .DEPTH_ATTACHMENT_OPTIMAL,
        load_op                         = .CLEAR,
        store_op                        = .DONT_CARE,
        clear_value.depth_stencil.depth = 1,
    };

    rendering_info := VK.Rendering_Info.{
        render_area = {
            offset = { x = 0, y = 0 },
            extent = renderer.swapchain_info.config.image_extent,
        },
        layer_count = 1,
        color_attachment_count = 1,
        p_color_attachments = *color_rendering_attachment_info,
        p_depth_attachment = *depth_rendering_attachment_info,
    };

    VK.cmd_bind_descriptor_sets(
        frame_resources.command_buffer,
        .GRAPHICS,
        renderer.graphics_pipeline_info.layout,
        0,
        .[renderer.global_descriptor_set],
        .[],
    );

    frame_constants: Frame_Constants;
    vertex_buffer := renderer.buffers[renderer.vertex_buffer_id - 1];
    material_buffer := renderer.buffers[renderer.material_buffer_id - 1];
    frame_constants.vertex_buffer_address = vertex_buffer.device_address;
    frame_constants.material_buffer_address = material_buffer.device_address;
    frame_constants.render_items_address = frame_resources.render_item_buffer.device_address;
    VK.cmd_push_constants(
        frame_resources.command_buffer,
        renderer.graphics_pipeline_info.layout,
        .VERTEX | .FRAGMENT,
        0,
        size_of(Frame_Constants),
        *frame_constants,
    );

    index_buffer := renderer.buffers[renderer.index_buffer_id - 1];

    VK.cmd_bind_index_buffer(frame_resources.command_buffer, index_buffer.buffer, 0, .UINT32);

    VK.cmd_begin_rendering(frame_resources.command_buffer, *rendering_info);

    viewport := VK.Viewport.{
        x         = 0,
        y         = xx renderer.swapchain_info.config.image_extent.height,
        width     = xx renderer.swapchain_info.config.image_extent.width,
        height    = -cast(float, renderer.swapchain_info.config.image_extent.height),
        min_depth = 0,
        max_depth = 1,
    };
    VK.cmd_set_viewport(frame_resources.command_buffer, VK.Viewport.[viewport]);

    scissor := VK.Rect_2D.{
        offset = {
            x = 0,
            y = 0,
        },
        extent = renderer.swapchain_info.config.image_extent,
    };
    VK.cmd_set_scissor(frame_resources.command_buffer, VK.Rect_2D.[scissor]);

    VK.cmd_bind_pipeline(frame_resources.command_buffer, .GRAPHICS, renderer.graphics_pipeline_info.pipeline);

    VK.cmd_draw_indexed_indirect(
        frame_resources.command_buffer,
        frame_resources.indirect_draw_buffer.buffer,
        offset = 0,
        draw_count = draw_index,
        stride = size_of(VK.Draw_Indexed_Indirect_Command),
    );

    VK.cmd_end_rendering(frame_resources.command_buffer);

    present_layout_barrier := VK.Image_Memory_Barrier_2.{
        src_stage_mask  = .COLOR_ATTACHMENT_OUTPUT,
        src_access_mask = .COLOR_ATTACHMENT_WRITE,
        dst_stage_mask  = .NONE,
        dst_access_mask = 0,
        old_layout      = .COLOR_ATTACHMENT_OPTIMAL,
        new_layout      = .PRESENT_SRC_KHR,
        image           = renderer.swapchain_info.images[image_index],
        subresource_range = {
            aspect_mask      = .COLOR,
            base_mip_level   = 0,
            level_count      = 1,
            base_array_layer = 0,
            layer_count      = 1,
        },
    };

    present_dependency_info := VK.Dependency_Info.{
        image_memory_barrier_count = 1,
        p_image_memory_barriers = *present_layout_barrier,
    };

    VK.cmd_pipeline_barrier_2(frame_resources.command_buffer, *present_dependency_info);

    VK.end_command_buffer(frame_resources.command_buffer);

    // Wait for swapchain image to be available for writing
    image_acquired_wait_info := VK.Semaphore_Submit_Info.{
        semaphore  = frame_resources.image_acquired_semaphore,
        stage_mask = .COLOR_ATTACHMENT_OUTPUT,
    };

    // Wait for the image to be presented
    semaphore_signals := VK.Semaphore_Submit_Info.[
        { // signals that rendering is completed
            semaphore = renderer.swapchain_info.render_complete_semaphores[image_index],
            stage_mask = .ALL_GRAPHICS,
        },
        { // signals that the entire frame is completed
            semaphore  = renderer.timeline_semaphore,
            value      = signal_value,
            stage_mask = .ALL_COMMANDS,
        },
    ];

    command_buffer_submit_info := VK.Command_Buffer_Submit_Info.{
        command_buffer = frame_resources.command_buffer,
    };

    submit_info := VK.Submit_Info_2.{
        wait_semaphore_info_count   = 1,
        p_wait_semaphore_infos      = *image_acquired_wait_info,
        command_buffer_info_count   = 1,
        p_command_buffer_infos      = *command_buffer_submit_info,
        signal_semaphore_info_count = semaphore_signals.count,
        p_signal_semaphore_infos    = semaphore_signals.data,
    };

    result = VK.queue_submit_2(renderer.graphics_queue, VK.Submit_Info_2.[submit_info], null);
    ASSERT_SUCCESS("Queue submit");

    present_info := VK.Present_Info_Khr.{
        wait_semaphore_count = 1,
        p_wait_semaphores    = *renderer.swapchain_info.render_complete_semaphores[image_index],
        swapchain_count      = 1,
        p_swapchains         = *renderer.swapchain_info.swapchain,
        p_image_indices      = *image_index,
        p_results            = null,
    };

    VK.queue_present_khr(renderer.graphics_queue, *present_info);
}



#scope_file

VERTEX_BUFFER_SIZE :: 64 * 1024 * 1024;
INDEX_BUFFER_SIZE  :: 32 * 1024 * 1024;

VULKAN_API_VERSION :: #run VK.make_version(1, 4, 350);

SURFACE_FORMAT :: VK.Format.B8G8R8A8_SRGB;
DEPTH_FORMAT   :: VK.Format.D32_SFLOAT;

// Is not tied to the number of swapchain images.
// Though, the number of swapchain images should not be less than the number of frames in flight
MAX_FRAMES_IN_FLIGHT_COUNT :: 2;

MAX_TEXTURES :: 256;
MAX_INDIRECT_BUFFER_SIZE :: 4096 * size_of(VK.Draw_Indexed_Indirect_Command);
MAX_RENDER_ITEM_BUFFER_SIZE :: 4096 * size_of(Render_Item);

ASSERT_SUCCESS :: (name: string) #expand {
    assert(`result == .SUCCESS, name);
}

create_indirect_draw_buffers :: (device: VK.Device, allocator: VMA.Allocator, frame_resources_list: []Frame_Resources) {
    for *frame_resources: frame_resources_list {
        frame_resources.indirect_draw_buffer = create_buffer(
            device,
            allocator,
            .INDIRECT_BUFFER,
            MAX_INDIRECT_BUFFER_SIZE,
            .AUTO,
            mappable = true,
        );
        result:, frame_resources.indirect_draw_pointer = VMA.map_memory(allocator, frame_resources.indirect_draw_buffer.allocation);
        ASSERT_SUCCESS("Map memory");

        frame_resources.render_item_buffer = create_buffer(
            device,
            allocator,
            .STORAGE_BUFFER | .SHADER_DEVICE_ADDRESS,
            MAX_RENDER_ITEM_BUFFER_SIZE,
            .AUTO,
            mappable = true,
        );
        result, frame_resources.render_item_pointer = VMA.map_memory(allocator, frame_resources.render_item_buffer.allocation);
        ASSERT_SUCCESS("Map memory");
    }
}

create_descriptor_sets :: (device: VK.Device) -> VK.Descriptor_Pool, VK.Descriptor_Set_Layout, VK.Descriptor_Set {
    descriptor_pool_sizes := VK.Descriptor_Pool_Size.[
        {
            type             = .COMBINED_IMAGE_SAMPLER,
            descriptor_count = MAX_TEXTURES,
        },
    ];

    descriptor_pool_create_info := VK.Descriptor_Pool_Create_Info.{
        flags           = .UPDATE_AFTER_BIND,
        max_sets        = 1,
        pool_size_count = descriptor_pool_sizes.count,
        p_pool_sizes      = descriptor_pool_sizes.data,
    };

    result, descriptor_pool := VK.create_descriptor_pool(device, *descriptor_pool_create_info);
    ASSERT_SUCCESS("Create descriptor pool");

    bindings := VK.Descriptor_Set_Layout_Binding.[
        {
            binding          = 0,
            descriptor_type  = .COMBINED_IMAGE_SAMPLER,
            descriptor_count = MAX_TEXTURES,
            stage_flags      = .FRAGMENT,
        },
    ];

    flags := VK.Descriptor_Binding_Flags.[
        .PARTIALLY_BOUND | .UPDATE_AFTER_BIND,
    ];

    flags_create_info := VK.Descriptor_Set_Layout_Binding_Flags_Create_Info.{
        binding_count   = flags.count,
        p_binding_flags = flags.data,
    };

    descriptor_set_layout_create_info := VK.Descriptor_Set_Layout_Create_Info.{
        p_next        = *flags_create_info,
        flags         = .UPDATE_AFTER_BIND_POOL,
        binding_count = bindings.count,
        p_bindings    = bindings.data,
    };

    result =, descriptor_set_layout := VK.create_descriptor_set_layout(device, *descriptor_set_layout_create_info);
    ASSERT_SUCCESS("Create descriptor set layout");

    descriptor_set_allocate_info := VK.Descriptor_Set_Allocate_Info.{
        descriptor_pool      = descriptor_pool,
        descriptor_set_count = 1,
        p_set_layouts        = *descriptor_set_layout,
    };

    result =, descriptor_sets := VK.allocate_descriptor_sets(device, *descriptor_set_allocate_info);
    defer array_free(descriptor_sets);

    return descriptor_pool, descriptor_set_layout, descriptor_sets[0];
}

add_buffer :: (buffers: *[..]GPU_Buffer, buffer: GPU_Buffer) -> id: int {
    array_add(buffers, buffer);

    return buffers.count;
}

create_sampler :: (device: VK.Device, sampler_create_info: VK.Sampler_Create_Info) -> VK.Sampler {
    result, sampler := VK.create_sampler(device, *sampler_create_info);
    ASSERT_SUCCESS("Create white pixel sampler");

    return sampler;
}

destroy_gpu_image :: (device: VK.Device, allocator: VMA.Allocator, gpu_image: GPU_Image) {
    VK.destroy_image_view(device, gpu_image.image_view);

    VMA.destroy_image(allocator, gpu_image.image, gpu_image.allocation);
}

create_white_pixel_image :: (
    queue:        VK.Queue,
    allocator:    VMA.Allocator,
    device:       VK.Device,
    command_pool: VK.Command_Pool,
) -> GPU_Image {
    white: u32 = 0xFFFFFFFF;

    white_pixel := Image.{
        width         = 1,
        height        = 1,
        channel_count = 4,
        data          = cast(*u8, *white),
    };

    command_buffer := start_transient_command_buffer(device, command_pool);

    gpu_image, staging_buffer := create_gpu_image(device, allocator, command_buffer, white_pixel);
    defer VMA.destroy_buffer(allocator, staging_buffer.buffer, staging_buffer.allocation);

    submit_transient_command_buffer(device, command_pool, queue, command_buffer);

    return gpu_image;
}

submit_transient_command_buffer :: (
    device: VK.Device,
    command_pool: VK.Command_Pool,
    queue: VK.Queue,
    command_buffer: VK.Command_Buffer,
) {
    VK.end_command_buffer(command_buffer);

    submit_info := VK.Submit_Info.{
        command_buffer_count = 1,
        p_command_buffers    = *command_buffer,
    };

    result := VK.queue_submit(queue, .[submit_info], null);
    ASSERT_SUCCESS("Submit transient command buffer");

    result = VK.queue_wait_idle(queue);
    ASSERT_SUCCESS("Submit transient command buffer wait");

    VK.free_command_buffers(device, command_pool, .[command_buffer]);
};

create_gpu_image :: (
    device: VK.Device,
    allocator: VMA.Allocator,
    command_buffer: VK.Command_Buffer,
    image: Image,
) -> GPU_Image, GPU_Buffer {
    gpu_image: GPU_Image = ---;

    image_create_info := VK.Image_Create_Info.{
        image_type = ._2D,
        format     = .R8G8B8A8_SRGB,
        extent     = {
            width  = xx image.width,
            height = xx image.height,
            depth  = 1,
        },
        mip_levels     = 1,
        array_layers   = 1,
        samples        = ._1,
        tiling         = .OPTIMAL,
        usage          = .TRANSFER_DST | .SAMPLED,
        initial_layout = .UNDEFINED,
    };

    allocation_create_info := VMA.Allocation_Create_Info.{ usage = .AUTO };

    result:, gpu_image.image, gpu_image.allocation = VMA.create_image(allocator, *image_create_info, *allocation_create_info);
    ASSERT_SUCCESS("Create image");

    image_view_create_info := VK.Image_View_Create_Info.{
        image     = gpu_image.image,
        view_type = ._2D,
        format    = image_create_info.format,
        subresource_range = {
            aspect_mask = .COLOR,
            level_count = 1,
            layer_count = 1,
        },
    };

    result, gpu_image.image_view = VK.create_image_view(device, *image_view_create_info);
    ASSERT_SUCCESS("Create image view");

    transfer_barrier := VK.Image_Memory_Barrier_2.{
        src_stage_mask  = .NONE,
        src_access_mask = .NONE,
        dst_stage_mask  = .COPY,
        dst_access_mask = .TRANSFER_WRITE,
        old_layout      = .UNDEFINED,
        new_layout      = .TRANSFER_DST_OPTIMAL,
        image           = gpu_image.image,
        subresource_range = {
            aspect_mask = .COLOR,
            level_count = 1,
            layer_count = 1,
        },
    };

    transfer_dependency_info := VK.Dependency_Info.{
        image_memory_barrier_count = 1,
        p_image_memory_barriers    = *transfer_barrier,
    };

    VK.cmd_pipeline_barrier_2(command_buffer, *transfer_dependency_info);

    byte_size := image.width * image.height * image.channel_count;
    staging_buffer := create_buffer(device, allocator, .TRANSFER_SRC, xx byte_size, .AUTO_PREFER_HOST, mappable = true);

    map_copy_buffer_data(allocator, staging_buffer, 0, image.data, byte_size);

    buffer_image_copy := VK.Buffer_Image_Copy.{
        image_subresource = {
            aspect_mask      = .COLOR,
            mip_level        = 0,
            base_array_layer = 0,
            layer_count      = 1,
        },
        image_extent = {
            width  = xx image.width,
            height = xx image.height,
            depth  = 1,
        },
    };

    VK.cmd_copy_buffer_to_image(
        command_buffer,
        staging_buffer.buffer,
        gpu_image.image,
        .TRANSFER_DST_OPTIMAL,
        1,
        *buffer_image_copy,
    );

    // Transition to a layout suitable for sampling
    shader_read_barrier := VK.Image_Memory_Barrier_2.{
        src_stage_mask  = .COPY,
        src_access_mask = .TRANSFER_WRITE,
        dst_stage_mask  = .FRAGMENT_SHADER,
        dst_access_mask = .SHADER_READ,
        old_layout      = .TRANSFER_DST_OPTIMAL,
        new_layout      = .SHADER_READ_ONLY_OPTIMAL,
        image           = gpu_image.image,
        subresource_range = {
            aspect_mask      = .COLOR,
            base_mip_level   = 0,
            level_count      = 1,
            base_array_layer = 0,
            layer_count      = 1,
        },
    };

    shader_read_dependency_info := VK.Dependency_Info.{
        image_memory_barrier_count = 1,
        p_image_memory_barriers    = *shader_read_barrier,
    };

    VK.cmd_pipeline_barrier_2(command_buffer, *shader_read_dependency_info);

    return gpu_image, staging_buffer;
}

map_copy_buffer_data :: (allocator: VMA.Allocator, buffer: GPU_Buffer, buffer_offset: u64, data: *void, byte_size: int) {
    result, buffer_pointer := VMA.map_memory(allocator, buffer.allocation);
    ASSERT_SUCCESS("Map memory");

    memcpy(buffer_pointer + buffer_offset, data, byte_size);

    VMA.unmap_memory(allocator, buffer.allocation);
}

create_buffer :: (
    device:       VK.Device,
    allocator:    VMA.Allocator,
    usage:        VK.Buffer_Usage_Flags,
    byte_size:    u64,
    memory_usage: VMA.Memory_Usage,
    mappable:     bool,
) -> GPU_Buffer {
    buffer: GPU_Buffer = ---;

    buffer_create_info := VK.Buffer_Create_Info.{
        size         = byte_size,
        usage        = usage,
        sharing_mode = .EXCLUSIVE,
    };

    allocation_create_info := VMA.Allocation_Create_Info.{
        flags = ifx mappable then VMA.Allocation_Create_Flags.HOST_ACCESS_SEQUENTIAL_WRITE else 0,
        usage = memory_usage,
    };

    result:, buffer.buffer, buffer.allocation, buffer.allocation_info = VMA.create_buffer(
        allocator,
        *buffer_create_info,
        *allocation_create_info,
    );
    ASSERT_SUCCESS("Create buffer");

    if (usage & .SHADER_DEVICE_ADDRESS) {
        vertex_buffer_device_address_info := VK.Buffer_Device_Address_Info.{
            buffer = buffer.buffer,
        };

        buffer.device_address = VK.get_buffer_device_address(device, *vertex_buffer_device_address_info);
    }

    return buffer;
}

start_transient_command_buffer :: (device: VK.Device, command_pool: VK.Command_Pool) -> VK.Command_Buffer {
    command_buffer_allocate_info := VK.Command_Buffer_Allocate_Info.{
        command_pool         = command_pool,
        level                = .PRIMARY,
        command_buffer_count = 1,
    };

    result, command_buffer := VK.allocate_command_buffer(device, *command_buffer_allocate_info);
    ASSERT_SUCCESS("Transient command buffer");

    command_buffer_begin_info := VK.Command_Buffer_Begin_Info.{
        flags = .ONE_TIME_SUBMIT,
    };

    result = VK.begin_command_buffer(command_buffer, *command_buffer_begin_info);
    ASSERT_SUCCESS("Begin transient command buffer");

    return command_buffer;
}

create_transient_command_pool :: (device: VK.Device, qfi: u32) -> VK.Command_Pool {
    command_pool_create_info := VK.Command_Pool_Create_Info.{
        flags              = .TRANSIENT,
        queue_family_index = qfi,
    };

    result, command_pool := VK.create_command_pool(device, *command_pool_create_info);
    ASSERT_SUCCESS("Transient command pool");

    return command_pool;
}

destroy_frame_resources :: (
    device: VK.Device,
    allocator: VMA.Allocator,
    frame_resources: *Frame_Resources,
) {
    VK.destroy_semaphore(device, frame_resources.image_acquired_semaphore);
    VK.destroy_command_pool(device, frame_resources.command_pool);

    VMA.unmap_memory(allocator, frame_resources.indirect_draw_buffer.allocation);
    VMA.destroy_buffer(allocator, frame_resources.indirect_draw_buffer.buffer, frame_resources.indirect_draw_buffer.allocation);
    VMA.unmap_memory(allocator, frame_resources.render_item_buffer.allocation);
    VMA.destroy_buffer(allocator, frame_resources.render_item_buffer.buffer, frame_resources.render_item_buffer.allocation);

    frame_resources.* = {};
}

create_frame_resources :: (
    device: VK.Device,
    qfi:    u32,
) -> frame_resources_list: [MAX_FRAMES_IN_FLIGHT_COUNT]Frame_Resources {
    frame_resources_list: [MAX_FRAMES_IN_FLIGHT_COUNT]Frame_Resources;
    for *frame_resources: frame_resources_list {
        semaphore_create_info: VK.Semaphore_Create_Info;
        result:, frame_resources.image_acquired_semaphore = VK.create_semaphore(device, *semaphore_create_info);
        ASSERT_SUCCESS("Image acquired semaphore");

        command_pool_create_info := VK.Command_Pool_Create_Info.{
            queue_family_index = qfi,
        };
        result, frame_resources.command_pool = VK.create_command_pool(device, *command_pool_create_info);
        ASSERT_SUCCESS("Command pool");

        command_buffer_allocate_info := VK.Command_Buffer_Allocate_Info.{
            command_pool         = frame_resources.command_pool,
            level                = .PRIMARY,
            command_buffer_count = 1,
        };
        result, frame_resources.command_buffer = VK.allocate_command_buffer(device, *command_buffer_allocate_info);
        ASSERT_SUCCESS("Command buffer");
    }

    return frame_resources_list;
}

create_timeline_semaphore :: (device: VK.Device) -> VK.Semaphore {
    semaphore_type_create_info := VK.Semaphore_Type_Create_Info.{
        semaphore_type = .TIMELINE,
        initial_value  = MAX_FRAMES_IN_FLIGHT_COUNT,
    };

    semaphore_create_info := VK.Semaphore_Create_Info.{
        p_next = *semaphore_type_create_info,
    };

    result, timeline_semaphore := VK.create_semaphore(device, *semaphore_create_info);
    ASSERT_SUCCESS("Timeline semaphore");

    return timeline_semaphore;
}

destroy_graphics_pipeline :: (device: VK.Device, graphics_pipeline_info: *Graphics_Pipeline_Info) {
    VK.destroy_pipeline_layout(device, graphics_pipeline_info.layout);

    VK.destroy_pipeline(device, graphics_pipeline_info.pipeline);

    graphics_pipeline_info.* = {};
}

create_graphics_pipeline :: (device: VK.Device, descriptor_set_layout: VK.Descriptor_Set_Layout) -> Graphics_Pipeline_Info {
    graphics_pipeline_info: Graphics_Pipeline_Info;

    { // Pipeline layout
        push_constant_range := VK.Push_Constant_Range.{
            stage_flags = .VERTEX | .FRAGMENT,
            offset      = 0,
            size        = size_of(Frame_Constants),
        };

        layout_create_info := VK.Pipeline_Layout_Create_Info.{
            set_layout_count          = 1,
            p_set_layouts             = *descriptor_set_layout,
            push_constant_range_count = 1,
            p_push_constant_ranges    = *push_constant_range,
        };

        result:, graphics_pipeline_info.layout = VK.create_pipeline_layout(device, *layout_create_info);
        ASSERT_SUCCESS("Pipeline layout");
    }

    vertex_shader := create_shader_module(device, "vertex.spv");
    defer VK.destroy_shader_module(device, vertex_shader);
    fragment_shader : = create_shader_module(device, "fragment.spv");
    defer VK.destroy_shader_module(device, fragment_shader);

    shader_stage_create_infos := VK.Pipeline_Shader_Stage_Create_Info.[
        {
            stage  = .VERTEX,
            module = vertex_shader,
            p_name = "main",
        },
        {
            stage  = .FRAGMENT,
            module = fragment_shader,
            p_name = "main",
        },
    ];

    vertex_input_state_create_info := VK.Pipeline_Vertex_Input_State_Create_Info.{};

    input_assembly_state_create_info := VK.Pipeline_Input_Assembly_State_Create_Info.{
        topology = .TRIANGLE_LIST,
    };

    depth_stencil_state_create_info := VK.Pipeline_Depth_Stencil_State_Create_Info.{
        depth_test_enable   = VK.TRUE,
        depth_write_enable  = VK.TRUE,
        depth_compare_op    = .LESS,
        stencil_test_enable = VK.FALSE,
    };

    viewport_state_create_info := VK.Pipeline_Viewport_State_Create_Info.{
        viewport_count = 1,
        p_viewports    = null,
        scissor_count  = 1,
        p_scissors     = null,
    };

    rasterization_state_create_info := VK.Pipeline_Rasterization_State_Create_Info.{
        polygon_mode = .FILL,
        cull_mode    = .BACK,
        front_face   = .COUNTER_CLOCKWISE,
        line_width   = 1,
    };

    multisample_state_create_info := VK.Pipeline_Multisample_State_Create_Info.{
        rasterization_samples = ._1,
    };

    color_blend_attachment_states := VK.Pipeline_Color_Blend_Attachment_State.[
        {
            blend_enable = VK.FALSE,
            color_write_mask = .R | .G | .B | .A,
        },
    ];

    color_blend_state_create_info := VK.Pipeline_Color_Blend_State_Create_Info.{
        attachment_count = color_blend_attachment_states.count,
        p_attachments    = color_blend_attachment_states.data,
    };

    dynamic_states := VK.Dynamic_State.[
        .VIEWPORT,
        .SCISSOR,
    ];

    dynamic_state_create_info := VK.Pipeline_Dynamic_State_Create_Info.{
        dynamic_state_count = dynamic_states.count,
        p_dynamic_states    = dynamic_states.data,
    };

    rendering_create_info := VK.Pipeline_Rendering_Create_Info.{
        color_attachment_count     = 1,
        p_color_attachment_formats = VK.Format.[SURFACE_FORMAT].data,
        depth_attachment_format    = DEPTH_FORMAT,
    };

    pipeline_create_info := VK.Graphics_Pipeline_Create_Info.{
        p_next                 = *rendering_create_info,
        stage_count            = shader_stage_create_infos.count,
        p_stages               = shader_stage_create_infos.data,
        p_vertex_input_state   = *vertex_input_state_create_info,
        p_input_assembly_state = *input_assembly_state_create_info,
        p_viewport_state       = *viewport_state_create_info,
        p_rasterization_state  = *rasterization_state_create_info,
        p_multisample_state    = *multisample_state_create_info,
        p_depth_stencil_state  = *depth_stencil_state_create_info,
        p_color_blend_state    = *color_blend_state_create_info,
        p_dynamic_state        = *dynamic_state_create_info,
        layout                 = graphics_pipeline_info.layout,
        render_pass            = null,
    };

    result:, graphics_pipeline_info.pipeline = VK.create_graphics_pipeline(device, null, *pipeline_create_info);
    ASSERT_SUCCESS("Graphics pipeline");

    return graphics_pipeline_info;
}

create_shader_module :: (device: VK.Device, name: string) -> VK.Shader_Module {
    path := tprint(
        "%/shaders/%",
        path_strip_filename(get_path_of_running_executable()),
        name,
    );

    file_content, ok := read_entire_file(path);
    assert(ok, "Failed to read file from '%'", path);
    defer free(file_content);

    shader_module_create_info := VK.Shader_Module_Create_Info.{
        code_size = xx (file_content.count * size_of(u8)),
        p_code    = cast(*u32, file_content.data),
    };

    result, shader_module := VK.create_shader_module(device, *shader_module_create_info);
    ASSERT_SUCCESS("Shader module");

    return shader_module;
}

destroy_depth_image :: (device: VK.Device, allocator: VMA.Allocator, depth_info: *GPU_Image) {
    destroy_gpu_image(device, allocator, depth_info);

    depth_info.* = {};
}

create_depth_image :: (device: VK.Device, swapchain_image_extent: VK.Extent_2D, allocator: VMA.Allocator) -> GPU_Image {
    depth_image: GPU_Image;

    { // Image
        image_create_info := VK.Image_Create_Info.{
            image_type = ._2D,
            format     = DEPTH_FORMAT,
            extent     = {
                width  = swapchain_image_extent.width,
                height = swapchain_image_extent.height,
                depth  = 1,
            },
            mip_levels     = 1,
            array_layers   = 1,
            samples        = ._1,
            tiling         = .OPTIMAL,
            usage          = .DEPTH_STENCIL_ATTACHMENT,
            initial_layout = .UNDEFINED,
        };

        allocation_create_info := VMA.Allocation_Create_Info.{
            flags = .DEDICATED_MEMORY,
            usage = .AUTO,
        };

        result:, depth_image.image, depth_image.allocation = VMA.create_image(allocator, *image_create_info, *allocation_create_info);
        ASSERT_SUCCESS("Depth image");
    }

    { // Image view
        image_view_create_info := VK.Image_View_Create_Info.{
            image             = depth_image.image,
            view_type         = ._2D,
            format            = DEPTH_FORMAT,
            subresource_range = {
                aspect_mask = .DEPTH,
                level_count = 1,
                layer_count = 1,
            },
        };

        result:, depth_image.image_view = VK.create_image_view(device, *image_view_create_info);
    }

    return depth_image;
}

destroy_swapchain :: (device: VK.Device, swapchain_info: *Swapchain_Info) {
    for semaphore: swapchain_info.render_complete_semaphores {
        VK.destroy_semaphore(device, semaphore);
    }
    array_free(swapchain_info.render_complete_semaphores);

    for image_view: swapchain_info.image_views {
        VK.destroy_image_view(device, image_view);
    }
    array_free(swapchain_info.image_views);

    array_free(swapchain_info.images);

    VK.destroy_swapchain_khr(device, swapchain_info.swapchain);

    swapchain_info.* = {};
}

create_swapchain :: (
    physical_device:       VK.Physical_Device,
    surface:               VK.Surface_Khr,
    device:                VK.Device,
    window:                Window_Type,
    get_window_pixel_size: Window_Pixel_Size_Getter,
    should_check_format    := false,
) -> Swapchain_Info {
    swapchain_info: Swapchain_Info;

    { // The swapchain itself
        result, surface_capabilities := VK.get_physical_device_surface_capabilities_khr(physical_device, surface);
        ASSERT_SUCCESS("Surface capabilities");

        desired_image_count := max(2, surface_capabilities.min_image_count); // @Todo: put 2 into a constant
        if surface_capabilities.max_image_count > 0 {
            desired_image_count = min(desired_image_count, surface_capabilities.max_image_count);
        }

        if should_check_format {
            supports_desired_format: bool;
            result, supported_formats := VK.get_physical_device_surface_formats_khr(physical_device, surface,, temp);
            ASSERT_SUCCESS("Supported surface formats");
            for supported_format: supported_formats {
                if supported_format.format == SURFACE_FORMAT {
                    supports_desired_format = true;
                    break;
                }
            }
            assert(supports_desired_format, "The desired surface format is not supported");
        }

        image_extent: VK.Extent_2D;
        if surface_capabilities.current_extent.width != U32_MAX {
            image_extent = surface_capabilities.current_extent;
        } else {
            width, height := get_window_pixel_size(window);

            image_extent.width = clamp(cast(u32, width), surface_capabilities.min_image_extent.width, surface_capabilities.max_image_extent.width);
            image_extent.height = clamp(cast(u32, height), surface_capabilities.min_image_extent.height, surface_capabilities.max_image_extent.height);
        }

        swapchain_info.config = {
            surface            = surface,
            min_image_count    = xx desired_image_count,
            image_format       = SURFACE_FORMAT,
            image_color_space  = .SRGB_NONLINEAR_KHR,
            image_extent       = image_extent,
            image_array_layers = 1,
            image_usage        = .COLOR_ATTACHMENT,
            pre_transform      = surface_capabilities.current_transform,
            composite_alpha    = .OPAQUE_KHR,
            present_mode       = .FIFO_KHR,
        };

        result, swapchain_info.swapchain = VK.create_swapchain_khr(device, *swapchain_info.config);
        ASSERT_SUCCESS("Swapchain");
    }

    result:, swapchain_info.images = VK.get_swapchain_images_khr(device, swapchain_info.swapchain);
    ASSERT_SUCCESS("Swapchain images");

    array_resize(*swapchain_info.image_views, swapchain_info.images.count);
    for image: swapchain_info.images {
        image_view_create_info := VK.Image_View_Create_Info.{
            image             = image,
            view_type         = ._2D,
            format            = swapchain_info.config.image_format,
            subresource_range = {
                aspect_mask      = .COLOR,
                base_mip_level   = 0,
                level_count      = 1,
                base_array_layer = 0,
                layer_count      = 1,
            },
        };

        result, image_view := VK.create_image_view(device, *image_view_create_info);
        ASSERT_SUCCESS("Swapchain image view");

        swapchain_info.image_views[it_index] = image_view;
    }

    array_resize(*swapchain_info.render_complete_semaphores, swapchain_info.images.count);
    for *semaphore: swapchain_info.render_complete_semaphores {
        semaphore_create_info: VK.Semaphore_Create_Info;

        result:, semaphore.* = VK.create_semaphore(device, *semaphore_create_info);
        ASSERT_SUCCESS("Render complete semaphore");
    }

    return swapchain_info;
}

init_vma :: (physical_device: VK.Physical_Device, device: VK.Device, instance: VK.Instance) -> VMA.Allocator {
    allocator_create_info := VMA.Allocator_Create_Info.{
        flags              = .BUFFER_DEVICE_ADDRESS,
        physical_device    = physical_device,
        device             = device,
        instance           = instance,
        vulkan_api_version = VULKAN_API_VERSION,
    };

    result, allocator := VMA.create_allocator(*allocator_create_info);
    ASSERT_SUCCESS("VMA allocator");

    return allocator;
}

create_device :: (physical_device: VK.Physical_Device, graphics_qfi: u32) -> VK.Device {
    {
        supported_features_14: VK.Physical_Device_Vulkan_1_4_Features;
        supported_features_13  := VK.Physical_Device_Vulkan_1_3_Features.{ p_next = *supported_features_14 };
        supported_features_12  := VK.Physical_Device_Vulkan_1_2_Features.{ p_next = *supported_features_13 };
        supported_features     := VK.Physical_Device_Features_2.{ p_next = *supported_features_12 };
        VK.get_physical_device_features_2(physical_device, *supported_features);

        assert(
            supported_features_13.dynamic_rendering
            && supported_features_13.synchronization_2
            && supported_features_12.timeline_semaphore
            && supported_features_12.buffer_device_address
            && supported_features_12.descriptor_binding_sampled_image_update_after_bind
            && supported_features_12.descriptor_binding_partially_bound
            && supported_features_12.scalar_block_layout
            && supported_features_12.runtime_descriptor_array
            && supported_features.features.multi_draw_indirect
            && supported_features.features.draw_indirect_first_instance
            && supported_features.features.shader_int64,
            "One of the required features is not supported",
        );
    }

    desired_features_14: VK.Physical_Device_Vulkan_1_4_Features;
    desired_features_13 := VK.Physical_Device_Vulkan_1_3_Features.{
        p_next            = *desired_features_14,
        synchronization_2 = VK.TRUE,
        dynamic_rendering = VK.TRUE,
    };
    desired_features_12 := VK.Physical_Device_Vulkan_1_2_Features.{
        p_next                                             = *desired_features_13,
        timeline_semaphore                                 = VK.TRUE,
        buffer_device_address                              = VK.TRUE,
        descriptor_binding_sampled_image_update_after_bind = VK.TRUE,
        descriptor_binding_partially_bound                 = VK.TRUE,
        scalar_block_layout                                = VK.TRUE,
        runtime_descriptor_array                           = VK.TRUE,
    };
    desired_features := VK.Physical_Device_Features_2.{
        p_next = *desired_features_12,
        features = {
            multi_draw_indirect          = VK.TRUE,
            shader_int64                 = VK.TRUE,
            draw_indirect_first_instance = VK.TRUE,
        }
    };

    queue_priorities := float.[1];
    device_queue_create_infos := VK.Device_Queue_Create_Info.[
        {
            queue_family_index = graphics_qfi,
            queue_count        = 1,
            p_queue_priorities = queue_priorities.data,
        },
    ];

    extensions: [..]*u8;
    extensions.allocator = temp;
    array_add(*extensions, VK.Extension_Names.KHR_SWAPCHAIN);

    device_create_info := VK.Device_Create_Info.{
        p_next                     = *desired_features,
        queue_create_info_count    = device_queue_create_infos.count,
        p_queue_create_infos       = device_queue_create_infos.data,
        enabled_extension_count    = xx extensions.count,
        pp_enabled_extension_names = extensions.data,
    };

    result, device := VK.create_device(physical_device, *device_create_info);
    ASSERT_SUCCESS("Device");

    return device;
}

find_graphics_queue_family_index :: (physical_device: VK.Physical_Device, surface: VK.Surface_Khr) -> u32 {
    graphics_qf_index := -1;

    qfps_list := VK.get_physical_device_queue_family_properties_2(physical_device,, temp);

    for qfps: qfps_list {
        result, has_present_support := VK.get_physical_device_surface_support_khr(physical_device, xx it_index, surface);
        ASSERT_SUCCESS("Surface support");

        if has_present_support && qfps.queue_family_properties.queue_flags & .GRAPHICS {
            graphics_qf_index = it_index;
            break;
        }
    }

    assert(graphics_qf_index >= 0, "Graphics queue family was not found");

    return xx graphics_qf_index;
}

find_physical_device :: (instance: VK.Instance) -> VK.Physical_Device {
    result, physical_devices := VK.enumerate_physical_devices(instance,, temp);
    ASSERT_SUCCESS("Enumerate physical devices");

    the_device: VK.Physical_Device;

    for candidate: physical_devices {
        candidate_props := VK.get_physical_device_properties(candidate);

        if candidate_props.device_type == .DISCRETE_GPU {
            the_device = candidate;
            break;
        }
    }

    if !the_device {
        assert(physical_devices.count > 0, "You don't have any GPU");
        the_device = physical_devices[0];
    }

    return the_device;
}

create_instance :: (get_additional_extensions: Additional_Instance_Extensions_Getter) -> VK.Instance {
    application_info := VK.Application_Info.{
        p_application_name = "Vulkaning",
        api_version = VULKAN_API_VERSION,
    };

    extensions: [..]*u8;
    extensions.allocator = temp;
    {
        additional_extensions := get_additional_extensions(,, temp);

        #if DEBUG {
            array_add(*extensions, VK.Extension_Names.DEBUG_UTILS);
        }

        for additional_extension: additional_extensions {
            array_add(*extensions, additional_extension);
        }
    }

    layers: [..]*u8;
    layers.allocator = temp;
    #if DEBUG {
        array_add(*layers, VK.Layer_Names.VALIDATION);
    }

    instance_create_info := VK.Instance_Create_Info.{
        p_application_info         = *application_info,
        enabled_layer_count        = xx layers.count,
        pp_enabled_layer_names     = layers.data,
        enabled_extension_count    = xx extensions.count,
        pp_enabled_extension_names = extensions.data,
    };

    #if DEBUG {
        debug_utils_messenger_create_info: VK.Debug_Utils_Messenger_Create_Info_Ext = {
            message_severity  = .VERBOSE_EXT    | .WARNING_EXT | .ERROR_EXT,
            message_type      = .VALIDATION_EXT | .PERFORMANCE_EXT,
            pfn_user_callback = debug_callback,
        };

        instance_create_info.p_next = *debug_utils_messenger_create_info;
    }

    result, instance := VK.create_instance(*instance_create_info);
    ASSERT_SUCCESS("Instance");

    return instance;
}

#if DEBUG {
    debug_callback: VK.Pfn_Debug_Utils_Messenger_Callback_Ext : (
        message_severity: VK.Debug_Utils_Message_Severity_Flags_Ext,
        message_types:    VK.Debug_Utils_Message_Type_Flags_Ext,
        p_callback_data:  *VK.Debug_Utils_Messenger_Callback_Data_Ext,
        p_user_data:      *void,
    ) -> VK.Bool #c_call {
        if message_severity >= .WARNING_EXT {
            push_context {
                print("VK Validation: %", to_string(p_callback_data.p_message,, temp));
            }
        }

        return VK.FALSE;
    }
}

#import "Basic";
#import "Math";
#import "System";
#import "String";
#import "File";
VK  :: #import "Jai_Vulkan";
VMA :: #import "Vulkan_Memory_Allocator"(DEBUG = DEBUG);
