#module_parameters()(Window_Type: Type, DEBUG := false);

Additional_Instance_Extensions_Getter :: #type () -> [..]*u8;
Surface_Creator :: #type (window: Window_Type, instance: *void, allocator: *void = null) -> *void;
Window_Pixel_Size_Getter :: #type (window: Window_Type) -> width: s32, height: s32;

Renderer :: struct {}

init :: (
    window:                             *void,
    get_additional_instance_extensions: Additional_Instance_Extensions_Getter,
    create_surface:                     Surface_Creator,
    get_window_pixel_size:              Window_Pixel_Size_Getter,
) -> Renderer {
    renderer: Renderer;

    return renderer;
}

deinit :: (renderer: *Renderer) {
    renderer.* = {};
}

render :: (renderer: *Renderer) {}



#scope_file

VULKAN_API_VERSION :: #run VK.make_version(1, 4, 350);

ASSERT_SUCCESS :: (name: string) #expand {
    assert(`result == .SUCCESS, name);
}

#import "Basic";
#import "Math";
#import "System";
#import "String";
VK  :: #import "Jai_Vulkan";
VMA :: #import "Vulkan_Memory_Allocator"(DEBUG = DEBUG);
