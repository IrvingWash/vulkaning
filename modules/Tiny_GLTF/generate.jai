#import "Basic";
#import "BuildCpp";
#import "File";
#import "Compiler";
#import "Bindings_Generator";

TINY_GLTF_PATH :: #run sprint("%tinygltf", #filepath);

BUILD_PATH :: #run tprint("%%", #filepath, OS);

#run {
    set_build_options_dc({
        do_output           = false,
        write_added_strings = false,
    });

    error := build();
    if error compiler_report(error, mode = .ERROR);

    error = generate_bindings();
    if error compiler_report(error, mode = .ERROR);
}

generate_bindings :: () -> error: string {
    output_filename := tprint("%%.jai", #filepath, OS);

    options: Generate_Bindings_Options;
    options.generate_library_declarations = false;
    array_add(*options.library_search_paths, BUILD_PATH);
    array_add(*options.include_paths, TINY_GLTF_PATH);
    array_add(*options.libraries, { filename="tinygltf" });
    array_add(
        *options.source_files,
        tprint("%/tiny_gltf_v3.h", TINY_GLTF_PATH),
        tprint("%/tinygltf_json_c.h", TINY_GLTF_PATH),
    );

    ok := generate_bindings(options, output_filename);
    if !ok {
        return "Failed to generate bindings";
    }

    return "";
}

build :: () -> error: string {
    RELEASE_LIB_NAME :: "tinygltf";
    DEBUG_LIB_NAME   :: "tinygltf_debug";

    ok := make_directory_if_it_does_not_exist(BUILD_PATH);
    if !ok {
        return tprint("Failed to create directory at %", BUILD_PATH);
    }

    ok = build_cpp_static_lib(
        tprint("%/%", BUILD_PATH, RELEASE_LIB_NAME),
        tprint("%/tiny_gltf_v3.c", TINY_GLTF_PATH),
        extra = string.[
            "-DTINYGLTF3_ENABLE_FS",
        ],
        debug = false,
    );
    if !ok {
        return "Failed to build the release version";
    }

    ok = build_cpp_static_lib(
        tprint("%/%", BUILD_PATH, DEBUG_LIB_NAME),
        tprint("%/tiny_gltf_v3.c", TINY_GLTF_PATH),
        extra = string.[
            "-DTINYGLTF3_ENABLE_FS",
        ],
        debug = true,
    );
    if !ok {
        return "Failed to build the debug version";
    }

    return "";
}
