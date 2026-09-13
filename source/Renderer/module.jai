#module_parameters()(Window_Type: Type, DEBUG := false);

Additional_Instance_Extensions_Getter :: #type () -> [..]*u8;
Surface_Creator                       :: #type (window: Window_Type, instance: *void, allocator: *void = null) -> *void;
Window_Pixel_Size_Getter              :: #type (window: Window_Type) -> width: s32, height: s32;

Renderer :: struct {
    instance: VK.Instance;
}

init :: (
    window:                             *void,
    get_additional_instance_extensions: Additional_Instance_Extensions_Getter,
    create_surface:                     Surface_Creator,
    get_window_pixel_size:              Window_Pixel_Size_Getter,
) -> Renderer {
    renderer: Renderer;

    renderer.instance = create_instance(get_additional_instance_extensions);

    return renderer;
}

deinit :: (renderer: *Renderer) {
    VK.destroy_instance(renderer.instance);

    renderer.* = {};
}

render :: (renderer: *Renderer) {}



#scope_file

VULKAN_API_VERSION :: #run VK.make_version(1, 4, 350);

ASSERT_SUCCESS :: (name: string) #expand {
    assert(`result == .SUCCESS, name);
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
    {
        #if DEBUG {
            array_add(*layers, VK.Layer_Names.VALIDATION);
        }
    }

    debug_utils_messenger_create_info := VK.Debug_Utils_Messenger_Create_Info_Ext.{
        message_severity = .VERBOSE_EXT | .WARNING_EXT | .ERROR_EXT,
        message_type = .VALIDATION_EXT | .PERFORMANCE_EXT,
        pfn_user_callback = debug_callback,
    };

    instance_create_info := VK.Instance_Create_Info.{
        p_next                     = *debug_utils_messenger_create_info,
        p_application_info         = *application_info,
        enabled_layer_count        = xx layers.count,
        pp_enabled_layer_names     = layers.data,
        enabled_extension_count    = xx extensions.count,
        pp_enabled_extension_names = extensions.data,
    };

    result, instance := VK.create_instance(*instance_create_info);
    ASSERT_SUCCESS("Instance");

    return instance;
}

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

#import "Basic";
#import "Math";
#import "System";
#import "String";
VK  :: #import "Jai_Vulkan";
VMA :: #import "Vulkan_Memory_Allocator"(DEBUG = DEBUG);
