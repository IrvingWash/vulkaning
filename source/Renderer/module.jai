#module_parameters()(Window_Type: Type, DEBUG := false);

Additional_Instance_Extensions_Getter :: #type () -> [..]*u8;
Surface_Creator :: #type (window: *Window_Type, instance: *void, allocator: *void = null) -> *void;

Renderer :: struct {
    instance:             VK.Instance;
    surface:              VK.Surface_Khr;
    physical_device:      VK.Physical_Device;
    graphics_queue_index: int;
}

init :: (
    window: *void,
    get_additional_instance_extensions: Additional_Instance_Extensions_Getter,
    create_surface: Surface_Creator,
) -> Renderer {
    renderer: Renderer;

    renderer.instance             = create_instance(get_additional_instance_extensions);
    renderer.surface              = create_surface(window, renderer.instance);
    renderer.physical_device      = find_physical_device(renderer.instance);
    renderer.graphics_queue_index = find_graphics_queue_index(renderer.physical_device, renderer.surface);

    return renderer;
}

deinit :: (renderer: *Renderer) {
    VK.destroy_surface_khr(renderer.instance, renderer.surface);

    VK.destroy_instance(renderer.instance);

    renderer.* = {};
}

#scope_file

find_graphics_queue_index :: (physical_device: VK.Physical_Device, surface: VK.Surface_Khr) -> int {
    queue_family_properties := VK.get_physical_device_queue_family_properties_2(physical_device);

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

find_physical_device :: (instance: VK.Instance) -> VK.Physical_Device {
    result, physical_devices := VK.enumerate_physical_devices(instance);
    assert(result == .SUCCESS);

    the_device: VK.Physical_Device;
    for device: physical_devices {
        properties := VK.get_physical_device_properties(device);

        if properties.device_type == .DISCRETE_GPU {
            the_device = device;
            break;
        }
    }

    assert(the_device != null);

    return the_device;
}

create_instance :: (get_additional_instance_extensions: Additional_Instance_Extensions_Getter)  -> VK.Instance {
    application_info: VK.Application_Info = {
        p_application_name = "Vulkaning",
        api_version = VK.make_version(1, 4, 350),
    };

    extensions: [..]*u8;
    {
        #if DEBUG {
            array_add(*extensions, VK.Extension_Names.DEBUG_UTILS);
        }

        additional_extensions := get_additional_instance_extensions();
        for additional: additional_extensions {
            array_add(*extensions, additional);
        }
    }

    layers: [..]*u8;
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
VK  :: #import "Jai_Vulkan";
