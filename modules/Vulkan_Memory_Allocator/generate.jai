#scope_file

#import "Basic";
#import "Compiler";
#import "BuildCpp";
#import "File";

VULKAN_INCLUDE_PATH :: #run tprint("%Vulkan-Headers/include", #filepath);

SRC_PATH :: #run tprint("%VulkanMemoryAllocator/include/vk_mem_alloc.h", #filepath);

#run {
    set_build_options_dc({ do_output = false });

    error := build_vma();
    if error {
        log_error("Failed to build VMA: %", error);
        compiler_set_workspace_status(.FAILED);
        return;
    }
}

build_vma :: () -> error: string {
    #if OS == {
        case .LINUX;
            ok := make_directory_if_it_does_not_exist(tprint("%%", #filepath, OS));
            if !ok {
                return "Failed to create build directory";
            }

            // Optimized
            ok = build_cpp_static_lib(
                tprint("%/libvma", OS),
                SRC_PATH,
                extra = .[
                    "-I",
                    VULKAN_INCLUDE_PATH,
                    "-DVMA_IMPLEMENTATION",
                    "-x",
                    "c++",
                    "-std=c++17",
                    "-fno-exceptions",
                    "-fno-rtti",
                    "-DNDEBUG"
                ],
                debug = false,
            );
            if !ok {
                return "Failed to build static library (optimized)";
            }

            // Debug
            ok = build_cpp_static_lib(
                tprint("%/libvma_debug", OS),
                SRC_PATH,
                extra = .[
                    "-I",
                    VULKAN_INCLUDE_PATH,
                    "-DVMA_IMPLEMENTATION",
                    "-x",
                    "c++",
                    "-std=c++17",
                    "-fno-exceptions",
                    "-fno-rtti",
                ],
                debug = true,
            );
            if !ok {
                return "Failed to build static library (debug)";
            }
        case .WINDOWS;
            ok := make_directory_if_it_does_not_exist(tprint("%%", #filepath, OS));
            if !ok {
                return "Failed to create build directory";
            }

            // Optimized
            ok = build_cpp_static_lib(
                tprint("%/libvma", OS),
                SRC_PATH,
                extra = .[
                    "/I",
                    VULKAN_INCLUDE_PATH,
                    "/DVMA_IMPLEMENTATION",
                    "/DVMA_CALL_PRE=__declspec(dllexport)",
                    "/TP",
                    "/DNDEBUG",
                ],
                debug = false,
            );
            if !ok {
                return "Failed to build static library (optimized)";
            }

            // Debug
            ok = build_cpp_static_lib(
                tprint("%/libvma_debug", OS),
                SRC_PATH,
                extra = .[
                    "/I",
                    VULKAN_INCLUDE_PATH,
                    "/DVMA_IMPLEMENTATION",
                    "/DVMA_CALL_PRE=__declspec(dllexport)",
                    "/TP",
                ],
                debug = true,
            );
            if !ok {
                return "Failed to build static library (debug)";
            }
        case;
            assert("Unsupported OS: '%'", OS);
    }

    return "";
}
