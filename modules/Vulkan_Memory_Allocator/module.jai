#module_parameters(DEBUG := false);

Allocator :: #type *Allocator_T;

Pfn_Allocate_Device_Memory_Function :: #type (
    allocator:   Allocator,
    memory_type: u32,
    memory:      Device_Memory,
    size:        Device_Size,
    p_user_data: *void,
) -> void #c_call;

Pfn_Free_Device_Memory_Function :: #type (
    allocator:   Allocator,
    memory_type: u32,
    memory:      Device_Memory,
    size:        Device_Size,
    p_user_data: *void,
) -> void #c_call;

Allocator_Create_Info :: struct {
    flags:                               Allocator_Create_Flags;
    physical_device:                     Physical_Device;
    device:                              Device;
    preferred_large_heap_block_size:     Device_Size;
    p_allocation_callbacks:              *Allocation_Callbacks;
    pDeviceMemoryCallbacks:              *Device_Memory_Callbacks;
    p_heap_size_limit:                   *Device_Size;
    p_vulkan_functions:                  *void; // @Todo: This is not an opaque struct. But it's huge and requires defining things not only here, but in Vulkan's bindings as well.
    instance:                            Instance;
    vulkan_api_version:                  u32;
    p_type_external_memory_handle_types: *External_Memory_Handle_Type_Flags_KHR;
}

Allocator_Create_Flags :: enum_flags u32 {
    EXTERNALLY_SYNCHRONIZED    :: 1;
    KHR_DEDICATED_ALLOCATION   :: 2;
    KHR_BIND_MEMORY2           :: 4;
    EXT_MEMORY_BUDGET          :: 8;
    AMD_DEVICE_COHERENT_MEMORY :: 16;
    BUFFER_DEVICE_ADDRESS      :: 32;
    EXT_MEMORY_PRIORITY        :: 64;
    KHR_MAINTENANCE4           :: 128;
    KHR_MAINTENANCE5           :: 256;
    KHR_EXTERNAL_MEMORY_WIN32  :: 512;
    FLAG_BITS_MAX_ENUM         :: 2147483647;
}

Device_Memory_Callbacks :: struct {
    pfn_allocate: Pfn_Allocate_Device_Memory_Function;
    pfn_free:     Pfn_Free_Device_Memory_Function;
    p_user_data:  *void;
};

External_Memory_Handle_Type_Flags_KHR :: enum_flags u32 {
    OPAQUE_FD                       :: 1;
    OPAQUE_WIN32                    :: 2;
    OPAQUE_WIN32_KMT                :: 4;
    D3D11_TEXTURE                   :: 8;
    D3D11_TEXTURE_KMT               :: 16;
    D3D12_HEAP                      :: 32;
    D3D12_RESOURCE                  :: 64;
    DMA_BUF_EXT                     :: 512;
    ANDROID_HARDWARE_BUFFER_ANDROID :: 1024;
    HOST_ALLOCATION_EXT             :: 128;
    HOST_MAPPED_FOREIGN_MEMORY_EXT  :: 256;
    ZIRCON_VMO_FUCHSIA              :: 2048;
    RDMA_ADDRESS_NV                 :: 4096;
    OH_NATIVE_BUFFER_OHOS           :: 32768;
    SCREEN_BUFFER_QNX               :: 16384;
    MTLBUFFER_EXT                   :: 65536;
    MTLTEXTURE_EXT                  :: 131072;
    MTLHEAP_EXT                     :: 262144;
    OPAQUE_FD_KHR                   :: 1;
    OPAQUE_WIN32_KHR                :: 2;
    OPAQUE_WIN32_KMT_KHR            :: 4;
    D3D11_TEXTURE_KHR               :: 8;
    D3D11_TEXTURE_KMT_KHR           :: 16;
    D3D12_HEAP_KHR                  :: 32;
    D3D12_RESOURCE_KHR              :: 64;
    FLAG_BITS_MAX_ENUM              :: 2147483647;
}

create_allocator :: inline (p_create_info: *Allocator_Create_Info) -> Result, Allocator {
    allocator: Allocator = ---;

    result := vmaCreateAllocator(p_create_info, *allocator);

    return result, allocator;
}

destroy_allocator :: (
    allocator: Allocator,
) -> void #foreign libvma "vmaDestroyAllocator";



#scope_file

Allocator_T :: struct {}

vmaCreateAllocator :: (
    p_create_info: *Allocator_Create_Info,
    p_allocator:   *Allocator,
) -> Result #foreign libvma;

#if OS == {
    case .LINUX;
        #library,system,link_always "libvulkan";
        #library,system,link_always "stdc++";
        #if DEBUG {
            libvma :: #library,no_dll "./LINUX/libvma_debug";
        } else {
            libvma :: #library,no_dll "./LINUX/libvma";
        }
    case .WINDOWS;
        #library,system,link_always "libcpmt";
        #if DEBUG {
            libvma :: #library,no_dll "./WINDOWS/libvma_debug";
        } else {
            libvma :: #library,no_dll "./WINDOWS/libvma";
        }
    case;
        assert(false, "Unsupported OS: %", OS);
}

#import "Jai_Vulkan";
