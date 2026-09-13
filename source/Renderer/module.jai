#module_parameters()(Window_Type: Type, DEBUG := false);

Additional_Instance_Extensions_Getter :: #type () -> [..]*u8;
Window_Pixel_Size_Getter              :: #type (window: Window_Type) -> width: s32, height: s32;

Surface_Creator :: #type (
    window: Window_Type,
    instance: VK.Instance,
    allocator: *void = null,
) -> ok: bool, VK.Surface_Khr;

Renderer :: struct {
    window: Window_Type;

    instance:        VK.Instance;
    surface:         VK.Surface_Khr;
    physical_device: VK.Physical_Device;

    // Graphics queue family index
    gfx_qfi: u32;

    device:    VK.Device;
    gfx_queue: VK.Queue;

    allocator: VMA.Allocator;
}

init :: (
    window:                             Window_Type,
    get_additional_instance_extensions: Additional_Instance_Extensions_Getter,
    create_surface:                     Surface_Creator,
    get_window_pixel_size:              Window_Pixel_Size_Getter,
) -> Renderer {
    renderer: Renderer;

    renderer.window = window;

    renderer.instance = create_instance(get_additional_instance_extensions);

    ok:, renderer.surface = create_surface(renderer.window, renderer.instance);
    assert(ok, "Failed to create surface");

    renderer.physical_device = find_physical_device(renderer.instance);

    renderer.gfx_qfi = find_graphics_queue_family_index(renderer.physical_device, renderer.surface);

    renderer.device = create_device(renderer.physical_device, renderer.gfx_qfi);

    renderer.gfx_queue = VK.get_device_queue(renderer.device, renderer.gfx_qfi, 0);

    renderer.allocator = init_vma(renderer.physical_device, renderer.device, renderer.instance);

    return renderer;
}

deinit :: (renderer: *Renderer) {
    VMA.destroy_allocator(renderer.allocator);

    VK.destroy_surface_khr(renderer.instance, renderer.surface);

    VK.destroy_device(renderer.device);

    VK.destroy_instance(renderer.instance);

    renderer.* = {};
}

render :: (renderer: *Renderer) {}



#scope_file

VULKAN_API_VERSION :: #run VK.make_version(1, 4, 350);

ASSERT_SUCCESS :: (name: string) #expand {
    assert(`result == .SUCCESS, name);
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

    requested_features_14: VK.Physical_Device_Vulkan_1_4_Features;
    requested_features_13 := VK.Physical_Device_Vulkan_1_3_Features.{
        p_next            = *requested_features_14,
        synchronization_2 = VK.TRUE,
        dynamic_rendering = VK.TRUE,
    };
    requested_features_12 := VK.Physical_Device_Vulkan_1_2_Features.{
        p_next             = *requested_features_13,
        timeline_semaphore = VK.TRUE,
    };
    requested_features := VK.Physical_Device_Features_2.{ p_next = *requested_features_12 };

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
        p_next                     = *requested_features,
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
