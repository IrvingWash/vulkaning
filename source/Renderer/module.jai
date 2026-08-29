#module_parameters()(DEBUG := false);

Additional_Instance_Extensions_Getter :: #type () -> [..]*u8;

init :: (get_additional_instance_extensions: Additional_Instance_Extensions_Getter) {
    instance := create_instance(get_additional_instance_extensions);
}

#scope_file

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
    assert(instance != null);

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
