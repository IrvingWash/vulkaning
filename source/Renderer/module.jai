#module_parameters()(Window_Type: Type, DEBUG := false);

Additional_Instance_Extensions_Getter :: #type () -> [..]*u8;
Surface_Creator :: #type (window: *Window_Type, instance: *void, allocator: *void = null) -> *void;
Window_Pixel_Size_Getter :: #type (window: *Window_Type) -> width: s32, height: s32;

Renderer :: struct {
    instance:             VK.Instance;
    surface:              VK.Surface_Khr;
    physical_device:      VK.Physical_Device;
    device:               VK.Device;

    graphics_queue_index: int;
    graphics_queue:       VK.Queue;

    swapchain: Swapchain;

    depth: Depth;

    allocator: VMA.Allocator;

    graphics_pipeline: Graphics_Pipeline;
}

Swapchain :: struct {
    swapchain: VK.Swapchain_Khr;
    config:    VK.Swapchain_Create_Info_Khr;
    images:    [..]VK.Image;
    views:     [..]VK.Image_View;

    render_complete_semaphores: [..]VK.Semaphore;

    IMAGE_FORMAT :: VK.Format.B8G8R8A8_SRGB;
}

Depth :: struct {
    image:      VK.Image;
    view:       VK.Image_View;
    allocation: VMA.Allocation;

    IMAGE_FORMAT     :: VK.Format.D32_SFLOAT;
}

Graphics_Pipeline :: struct {
    layout:   VK.Pipeline_Layout;
    pipeline: VK.Pipeline;
}

init :: (
    window:                             *void,
    get_additional_instance_extensions: Additional_Instance_Extensions_Getter,
    create_surface:                     Surface_Creator,
    get_window_pixel_size:              Window_Pixel_Size_Getter,
) -> Renderer {
    renderer: Renderer;

    renderer.instance             = create_instance(get_additional_instance_extensions);
    renderer.surface              = create_surface(window, renderer.instance);
    renderer.physical_device      = find_physical_device(renderer.instance, renderer.surface);
    renderer.graphics_queue_index = find_graphics_queue_index(renderer.physical_device, renderer.surface);
    renderer.device               = create_device(renderer.physical_device, renderer.graphics_queue_index);
    renderer.graphics_queue       = VK.get_device_queue(renderer.device, xx renderer.graphics_queue_index, 0);

    renderer.swapchain = create_swapchain(
        renderer.physical_device,
        renderer.surface,
        renderer.device,
        window,
        get_window_pixel_size,
        null,
    );

    renderer.allocator = init_vma(renderer);

    renderer.depth = create_depth_image(renderer.device, renderer.allocator, renderer.swapchain.config);

    renderer.graphics_pipeline = create_graphics_pipeline(renderer.device, renderer.swapchain);

    return renderer;
}

deinit :: (renderer: *Renderer) {
    VK.destroy_pipeline(renderer.device, renderer.graphics_pipeline.pipeline);
    VK.destroy_pipeline_layout(renderer.device, renderer.graphics_pipeline.layout);

    destroy_depth(renderer.device, renderer.allocator, *renderer.depth);

    destroy_swapchain(renderer.device, *renderer.swapchain);

    VMA.destroy_allocator(renderer.allocator);

    VK.destroy_surface_khr(renderer.instance, renderer.surface);

    VK.destroy_device(renderer.device);

    VK.destroy_instance(renderer.instance);

    renderer.* = {};
}



#scope_file

VULKAN_API_VERSION :: #run VK.make_version(1, 4, 350);

create_graphics_pipeline :: (device: VK.Device, swapchain: Swapchain) -> Graphics_Pipeline {
    graphics_pipeline: Graphics_Pipeline;

    {
        pipeline_layout_create_info := VK.Pipeline_Layout_Create_Info.{
            set_layout_count          = 0,
            push_constant_range_count = 0,
        };

        result:, graphics_pipeline.layout = VK.create_pipeline_layout(device, *pipeline_layout_create_info);
        assert(result == .SUCCESS);
    }

    exe_path := path_strip_filename(get_path_of_running_executable());
    vertex_shader   := create_shader_module(device, tprint("%shaders/vertex.spv", exe_path));
    fragment_shader := create_shader_module(device, tprint("%shaders/fragment.spv", exe_path));
    defer VK.destroy_shader_module(device, vertex_shader);
    defer VK.destroy_shader_module(device, fragment_shader);

    ENTRY_POINT_NAME :: "main";
    shader_stage_create_infos := VK.Pipeline_Shader_Stage_Create_Info.[
        {
            stage = .VERTEX,
            module = vertex_shader,
            p_name = ENTRY_POINT_NAME
        },
        {
            stage = .FRAGMENT,
            module = fragment_shader,
            p_name = ENTRY_POINT_NAME,
        },
    ];

    vertex_input_state_create_info: VK.Pipeline_Vertex_Input_State_Create_Info;

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
        scissor_count  = 1,
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

    color_blend_attachment_state := VK.Pipeline_Color_Blend_Attachment_State.{
        blend_enable = VK.FALSE,
        color_write_mask = .R | .G | .B | .A,
    };

    color_blend_state_create_info := VK.Pipeline_Color_Blend_State_Create_Info.{
        attachment_count = 1,
        p_attachments    = *color_blend_attachment_state,
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
        p_color_attachment_formats = *swapchain.config.image_format,
        depth_attachment_format    = Depth.IMAGE_FORMAT,
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
        layout                 = graphics_pipeline.layout,
        render_pass            = null,
    };

    result:, graphics_pipeline.pipeline = VK.create_graphics_pipeline(device, null, *pipeline_create_info);
    assert(result == .SUCCESS);

    return graphics_pipeline;
}

create_shader_module :: (device: VK.Device, path: string) -> VK.Shader_Module {
    File :: #import "File";

    file_content, ok := File.read_entire_file(path);
    assert(ok);
    defer free(file_content);

    shader_module_create_info := VK.Shader_Module_Create_Info.{
        code_size = cast(u64, file_content.count * size_of(u8)),
        p_code    = cast(*u32, file_content.data),
    };

    result, shader_module := VK.create_shader_module(device, *shader_module_create_info);
    assert(result == .SUCCESS);

    return shader_module;
}

destroy_depth :: (device: VK.Device, allocator: VMA.Allocator, depth: *Depth) {
    VK.destroy_image_view(device, depth.view);
    VMA.destroy_image(allocator, depth.image, depth.allocation);

    depth.* = {};
}

destroy_swapchain :: (device: VK.Device, swapchain: *Swapchain) {
    for image_view: swapchain.views {
        VK.destroy_image_view(device, image_view);
    }
    array_free(swapchain.views);
    array_free(swapchain.images);

    for swapchain.render_complete_semaphores {
        VK.destroy_semaphore(device, it);
    }
    array_free(swapchain.render_complete_semaphores);

    VK.destroy_swapchain_khr(device, swapchain.swapchain);

    swapchain.* = {};
}

create_depth_image :: (
    device: VK.Device,
    allocator: VMA.Allocator,
    swapchain_config: VK.Swapchain_Create_Info_Khr,
) -> Depth {
    depth: Depth;

    image_create_info := VK.Image_Create_Info.{
        image_type = ._2D,
        format     = Depth.IMAGE_FORMAT,
        extent     = {
            width  = swapchain_config.image_extent.width,
            height = swapchain_config.image_extent.height,
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

    result:, depth.image, depth.allocation = VMA.create_image(allocator, *image_create_info, *allocation_create_info);
    assert(result == .SUCCESS);

    image_view_create_info := VK.Image_View_Create_Info.{
        image             = depth.image,
        view_type         = ._2D,
        format            = Depth.IMAGE_FORMAT,
        subresource_range = {
            aspect_mask = .DEPTH,
            level_count = 1,
            layer_count = 1,
        },
    };

    result, depth.view = VK.create_image_view(device, *image_view_create_info);
    assert(result == .SUCCESS);

    return depth;
}

create_render_complete_semaphores :: (device: VK.Device, swapchain_images: []VK.Image) -> [..]VK.Semaphore {
    semaphores: [..]VK.Semaphore;
    array_resize(*semaphores, swapchain_images.count);

    for *semaphore: semaphores {
        create_info: VK.Semaphore_Create_Info;

        result:, semaphore.* = VK.create_semaphore(device, *create_info);
        assert(result == .SUCCESS);
    }

    return semaphores;
}

get_swapchain_images :: (device: VK.Device, swapchain: Swapchain) -> [..]VK.Image, [..]VK.Image_View {
     result, images := VK.get_swapchain_images_khr(device, swapchain.swapchain);
     assert(result == .SUCCESS);

     image_views: [..]VK.Image_View;
     for image: images {
         image_view_create_info := VK.Image_View_Create_Info.{
             image             = image,
             view_type         = ._2D,
             format            = swapchain.config.image_format,
             subresource_range = {
                 aspect_mask      = .COLOR,
                 base_mip_level   = 0,
                 level_count      = 1,
                 base_array_layer = 0,
                 layer_count      = 1,
             },
         };

          result, image_view := VK.create_image_view(device, *image_view_create_info);
          assert(result == .SUCCESS);

          array_add(*image_views, image_view);
     }

     return images, image_views;
}

create_swapchain :: (
    physical_device:       VK.Physical_Device,
    surface:               VK.Surface_Khr,
    device:                VK.Device,
    window:                *Window_Type,
    get_window_pixel_size: Window_Pixel_Size_Getter,
    old_swapchain:         VK.Swapchain_Khr,
) -> Swapchain {
    swapchain: Swapchain;

    result, surface_capabilities := VK.get_physical_device_surface_capabilities_khr(physical_device, surface);
    assert(result == .SUCCESS);

    SWAPCHAIN_IMAGES_COUNT :: 2;
    image_count_to_request := max(SWAPCHAIN_IMAGES_COUNT, surface_capabilities.min_image_count);
    if surface_capabilities.max_image_count > 0 {
        image_count_to_request = min(image_count_to_request, surface_capabilities.max_image_count);
    }

    image_extent: VK.Extent_2D;
    if surface_capabilities.current_extent.width != U32_MAX {
        image_extent = surface_capabilities.current_extent;
    } else {
        width, height := get_window_pixel_size(window);
        image_extent.width = clamp(cast(u32, width), surface_capabilities.min_image_extent.width, surface_capabilities.max_image_extent.width);
        image_extent.height = clamp(cast(u32, height), surface_capabilities.min_image_extent.height, surface_capabilities.max_image_extent.height);
    }

    swapchain.config = VK.Swapchain_Create_Info_Khr.{
        surface            = surface,
        min_image_count    = xx image_count_to_request,
        image_format       = Swapchain.IMAGE_FORMAT, // We check if this format is supported earlier, when we look for the physical device
        image_color_space  = .SRGB_NONLINEAR_KHR,
        image_extent       = image_extent,
        image_array_layers = 1,
        image_usage        = .COLOR_ATTACHMENT,
        pre_transform      = surface_capabilities.current_transform,
        composite_alpha    = .OPAQUE_KHR,
        present_mode       = .FIFO_KHR,
        old_swapchain      = old_swapchain,
    };

    result, swapchain.swapchain = VK.create_swapchain_khr(device, *swapchain.config);
    assert(result == .SUCCESS);

    swapchain.images,
    swapchain.views = get_swapchain_images(device, swapchain);

    swapchain.render_complete_semaphores = create_render_complete_semaphores(device, swapchain.images);

    return swapchain;
}

init_vma :: (renderer: Renderer) -> VMA.Allocator {
    allocator_create_info := VMA.Allocator_Create_Info.{
        flags              = .BUFFER_DEVICE_ADDRESS,
        physical_device    = renderer.physical_device,
        device             = renderer.device,
        instance           = renderer.instance,
        vulkan_api_version = VULKAN_API_VERSION,
    };

    result, allocator := VMA.create_allocator(*allocator_create_info);
    assert(result == .SUCCESS);

    return allocator;
}

create_device :: (physical_device: VK.Physical_Device, graphics_queue_index: int) -> VK.Device {
    { // Check feature support
        supported_feats_1_4: VK.Physical_Device_Vulkan_1_4_Features;
        supported_feats_1_3 := VK.Physical_Device_Vulkan_1_3_Features.{
            p_next = *supported_feats_1_4,
        };
        supported_feats_1_2 := VK.Physical_Device_Vulkan_1_2_Features.{
            p_next = *supported_feats_1_3,
        };
        supported_feats := VK.Physical_Device_Features_2.{
            p_next = *supported_feats_1_2,
        };

        VK.get_physical_device_features_2(physical_device, *supported_feats);
        assert(
            supported_feats_1_3.dynamic_rendering
            && supported_feats_1_3.synchronization_2
            && supported_feats_1_2.timeline_semaphore
        );
    }

    feats_1_4: VK.Physical_Device_Vulkan_1_4_Features;
    feats_1_3 := VK.Physical_Device_Vulkan_1_3_Features.{
        p_next            = *feats_1_4,
        synchronization_2 = VK.TRUE,
        dynamic_rendering = VK.TRUE,
    };
    feats_1_2 := VK.Physical_Device_Vulkan_1_2_Features.{
        p_next             = *feats_1_3,
        timeline_semaphore = VK.TRUE,
    };
    feats := VK.Physical_Device_Features_2.{
        p_next = *feats_1_2,
    };

    queue_priorities := float.[1];
    graphics_queue_create_info := VK.Device_Queue_Create_Info.{
        queue_family_index = xx graphics_queue_index,
        queue_count        = queue_priorities.count,
        p_queue_priorities = queue_priorities.data,
    };

    extensions := *u8.[
        VK.Extension_Names.KHR_SWAPCHAIN,
    ];

    device_create_info := VK.Device_Create_Info.{
        p_next                     = *feats,
        queue_create_info_count    = 1,
        p_queue_create_infos       = *graphics_queue_create_info,
        enabled_extension_count    = extensions.count,
        pp_enabled_extension_names = extensions.data,
    };

    result, device := VK.create_device(physical_device, *device_create_info);
    assert(result == .SUCCESS);

    return device;
}

find_graphics_queue_index :: (physical_device: VK.Physical_Device, surface: VK.Surface_Khr) -> int {
    queue_family_properties := VK.get_physical_device_queue_family_properties_2(physical_device,, temp);

    the_index: int = -1;
    for qf: queue_family_properties {
        properties           := queue_family_properties[it_index];
        ok, is_surface_supported := VK.get_physical_device_surface_support_khr(physical_device, xx it_index, surface);
        assert(ok == .SUCCESS);

        if (
            properties.queue_family_properties.queue_flags & .GRAPHICS
            && is_surface_supported
        ) {
            the_index = it_index;
            break;
        }
    }

    assert(the_index >= 0);

    return the_index;
}

find_physical_device :: (instance: VK.Instance, surface: VK.Surface_Khr) -> VK.Physical_Device {
    result, physical_devices := VK.enumerate_physical_devices(instance,, temp);
    assert(result == .SUCCESS);

    the_device: VK.Physical_Device;
    for device: physical_devices {
        properties := VK.get_physical_device_properties(device);

        if properties.device_type == .DISCRETE_GPU {
            the_device = device;
            break;
        }
    }

    { // Check if the hardcoded swapchain image format is supported
        result, surface_formats := VK.get_physical_device_surface_formats_khr(the_device, surface,, temp);
        assert(result == .SUCCESS);

        have_the_needed_format: bool;
        for format: surface_formats {
            if format.format == Swapchain.IMAGE_FORMAT {
                have_the_needed_format = true;
                break;
            }
        }

        assert(have_the_needed_format);
    }

    assert(the_device != null);

    return the_device;
}

create_instance :: (get_additional_instance_extensions: Additional_Instance_Extensions_Getter)  -> VK.Instance {
    application_info: VK.Application_Info = {
        p_application_name = "Vulkaning",
        api_version        = VULKAN_API_VERSION,
    };

    extensions: [..]*u8;
    extensions.allocator = temp;
    {
        #if DEBUG {
            array_add(*extensions, VK.Extension_Names.DEBUG_UTILS);
        }

        additional_extensions := get_additional_instance_extensions(,, temp);
        for additional: additional_extensions {
            array_add(*extensions, additional);
        }
    }

    layers: [..]*u8;
    layers.allocator = temp;
    {
        #if DEBUG {
            array_add(*layers, VK.Layer_Names.VALIDATION);
        }
    }

    debug_messenger_create_info: VK.Debug_Utils_Messenger_Create_Info_Ext = {
        message_severity  = .VERBOSE_EXT    | .WARNING_EXT | .ERROR_EXT,
        message_type      = .VALIDATION_EXT | .PERFORMANCE_EXT,
        pfn_user_callback = on_debug_message,
    };

    instance_create_info := VK.Instance_Create_Info.{
        p_next = *debug_messenger_create_info,
        p_application_info = *application_info,
        enabled_layer_count = xx layers.count,
        pp_enabled_layer_names = layers.data,
        enabled_extension_count = xx extensions.count,
        pp_enabled_extension_names = extensions.data,
    };

    result, instance := VK.create_instance(*instance_create_info);
    assert(result == .SUCCESS);

    return instance;
}

on_debug_message: VK.Pfn_Debug_Utils_Messenger_Callback_Ext : (
    message_severity: VK.Debug_Utils_Message_Severity_Flags_Ext,
    message_types:    VK.Debug_Utils_Message_Type_Flags_Ext,
    p_callback_data:  *VK.Debug_Utils_Messenger_Callback_Data_Ext,
    p_user_data:      *void,
) -> VK.Bool #c_call {
    if message_severity >= .WARNING_EXT {
        push_context {
            print("Validation layer: %\n", p_callback_data.p_message, to_standard_error = true);
        }
    }

    return VK.FALSE;
}

#import "Basic";
#import "Math";
#import "System";
#import "String";
VK  :: #import "Jai_Vulkan";
VMA :: #import "Vulkan_Memory_Allocator"(DEBUG = DEBUG);
