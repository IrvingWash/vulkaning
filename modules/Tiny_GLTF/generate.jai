#import "Basic";
#import "BuildCpp";
#import "File";
#import "Compiler";

TINY_GLTF_PATH :: #run sprint("%tinygltf", #filepath);

#run {
    set_build_options_dc({ do_output = false });

    error := build();
    if error compiler_report(error, mode = .ERROR);

    error = generate_bindings();
    if error compiler_report(error, mode = .ERROR);
}

generate_bindings :: () -> error: string {
    return "";
}

build :: () -> error: string {
    RELEASE_LIB_NAME :: "tinygltf";
    DEBUG_LIB_NAME   :: "tinygltf_debug";

    output_path := tprint("%%", #filepath, OS);

    ok := make_directory_if_it_does_not_exist(output_path);
    if !ok {
        return tprint("Failed to create directory at %", output_path);
    }

    ok = build_cpp_static_lib(
        tprint("%/%", output_path, RELEASE_LIB_NAME),
        tprint("%/tiny_gltf_v3.c", TINY_GLTF_PATH),
        debug = false,
    );
    if !ok {
        return "Failed to build the release version";
    }

    ok = build_cpp_static_lib(
        tprint("%/%", output_path, DEBUG_LIB_NAME),
        tprint("%/tiny_gltf_v3.c", TINY_GLTF_PATH),
        debug = true,
    );
    if !ok {
        return "Failed to build the debug version";
    }

    return "";
}
