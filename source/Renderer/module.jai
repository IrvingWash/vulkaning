#module_parameters()(Window_Type: Type, DEBUG := false);

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

    // Graphics queue family index
    gfx_qfi: u32;

    device:    VK.Device;
    gfx_queue: VK.Queue;

    allocator: VMA.Allocator;

    swapchain_info: Swapchain_Info;
    depth_info:     Depth_Info;
}

Swapchain_Info :: struct {
    swapchain:   VK.Swapchain_Khr;
    config:      VK.Swapchain_Create_Info_Khr;
    images:      [..]VK.Image;
    image_views: [..]VK.Image_View;

    render_complete_semaphores: [..]VK.Semaphore;
}

Depth_Info :: struct {
    image:      VK.Image;
    allocation: VMA.Allocation;
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

    renderer.gfx_qfi = find_graphics_queue_family_index(renderer.physical_device, renderer.surface);

    renderer.device = create_device(renderer.physical_device, renderer.gfx_qfi);

    renderer.gfx_queue = VK.get_device_queue(renderer.device, renderer.gfx_qfi, 0);

    renderer.allocator = init_vma(renderer.physical_device, renderer.device, renderer.instance);

    renderer.swapchain_info = create_swapchain(
        renderer.physical_device,
        renderer.surface,
        renderer.device,
        renderer.window,
        renderer.get_window_pixel_size,
        should_check_format = true,
    );

    renderer.depth_info = create_depth(renderer.swapchain_info.config.image_extent, renderer.allocator);

    return renderer;
}

deinit :: (renderer: *Renderer) {
    destroy_depth(renderer.allocator, *renderer.depth_info);

    destroy_swapchain(renderer.device, *renderer.swapchain_info);

    VMA.destroy_allocator(renderer.allocator);

    VK.destroy_surface_khr(renderer.instance, renderer.surface);

    VK.destroy_device(renderer.device);

    VK.destroy_instance(renderer.instance);

    renderer.* = {};
}

render :: (renderer: *Renderer) {}



#scope_file

VULKAN_API_VERSION :: #run VK.make_version(1, 4, 350);

SURFACE_FORMAT :: VK.Format.B8G8R8A8_SRGB;
DEPTH_FORMAT   :: VK.Format.D32_SFLOAT;

ASSERT_SUCCESS :: (name: string) #expand {
    assert(`result == .SUCCESS, name);
}

destroy_depth :: (allocator: VMA.Allocator, depth_info: *Depth_Info) {
    VMA.destroy_image(allocator, depth_info.image, depth_info.allocation);

    depth_info.* = {};
}

create_depth :: (swapchain_image_extent: VK.Extent_2D, allocator: VMA.Allocator) -> Depth_Info {
    depth_info: Depth_Info;

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

    result:, depth_info.image, depth_info.allocation = VMA.create_image(allocator, *image_create_info, *allocation_create_info);
    ASSERT_SUCCESS("Depth image");

    return depth_info;
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

create_device :: (physical_device: VK.Physical_Device, gfx_qfi: u32) -> VK.Device {
    {
        supported_features_14: VK.Physical_Device_Vulkan_1_4_Features;
        supported_features_13  := VK.Physical_Device_Vulkan_1_3_Features.{ p_next = *supported_features_14 };
        supported_features_12  := VK.Physical_Device_Vulkan_1_2_Features.{ p_next = *supported_features_13 };
        supported_features     := VK.Physical_Device_Features_2.{ p_next = *supported_features_12 };
        VK.get_physical_device_features_2(physical_device, *supported_features);

        assert(
            supported_features_13.dynamic_rendering
            && supported_features_13.synchronization_2
            && supported_features_12.timeline_semaphore,
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
        p_next             = *desired_features_13,
        timeline_semaphore = VK.TRUE,
    };
    desired_features := VK.Physical_Device_Features_2.{ p_next = *desired_features_12 };

    queue_priorities := float.[1];
    device_queue_create_infos := VK.Device_Queue_Create_Info.[
        {
            queue_family_index = gfx_qfi,
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
VK  :: #import "Jai_Vulkan";
VMA :: #import "Vulkan_Memory_Allocator"(DEBUG = DEBUG);
