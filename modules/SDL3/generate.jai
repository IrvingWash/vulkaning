#scope_file

#import "Basic";
#import "Compiler";
#import "Process";
#import "File";
#import "File_Utilities";
#import "Bindings_Generator";

SDL_PATH :: "./SDL";

#run {
    set_build_options_dc({
        do_output = false,
        write_added_strings = false
    });

    print("Building SDL library\n");
    error := build_library();
    if error {
        print("Failed to build SDL library: %", error, to_standard_error = true);
        exit(1);
    }

    print("Generating SDL bindings\n");
    error = generate_bindings();
    if error {
        print("Failed to generate SDL bindings: %", error, to_standard_error = true);
        exit(1);
    }
}

generate_bindings :: () -> error: string {
    output_filename: string;
    options: Generate_Bindings_Options;

    options.generate_library_declarations = false;
    options.generate_compile_time_struct_checks = false;

    absolute_include_path := tprint("%%/include", #filepath, SDL_PATH);

    array_add(*options.include_paths, absolute_include_path);
    array_add(*options.source_files, tprint("%/SDL3/SDL.h", absolute_include_path));
    array_add(*options.source_files, tprint("%/SDL3/SDL_vulkan.h", absolute_include_path));

    #if OS == {
        case .LINUX;
            output_filename = tprint("%linux.jai", #filepath);

            array_add(*options.libraries, { filename = "libSDL3.so" });
        case;
            return tprint("Unsupport OS %", OS);
    }

    ok := generate_bindings(options, output_filename);
    if !ok {
        return "Bindings Generator failed";
    }

    return "";
}

build_library :: () -> error: string {
    absolute_install_path := tprint("%%", #filepath, OS);
    {
        ok := make_directory_if_it_does_not_exist(absolute_install_path);
        if !ok {
            return tprint("Failed to create install directory at %", absolute_install_path);
        }
    }

    absolute_artefact_path := tprint("%/artefacts", absolute_install_path);
    {
        ok := make_directory_if_it_does_not_exist(absolute_artefact_path);
        if !ok {
            return tprint("Failed to create artefacts directory at %", absolute_artefact_path);
        }
    }

    absolute_sdl_path := get_absolute_path(SDL_PATH);


    { // Configuring cmake
        result, _, error, _ := run_command(
            ..string.[
                "cmake",
                "-S", absolute_sdl_path,
                "-B", absolute_artefact_path,
                tprint("-DCMAKE_INSTALL_PREFIX=%", absolute_install_path),
                tprint("-DCMAKE_PREFIX_PATH=%", absolute_install_path),
                "-DCMAKE_BUILD_TYPE=Release",
            ],
            capture_and_return_output = true,
        );

        if error {
            return error;
        }

        if result.exit_code != 0 {
            return "Failed to configure cmake";
        }
    }

    { // Build SDL
        result, _, error, _ := run_command(
            ..string.[
                "cmake",
                "--build",
                absolute_artefact_path,
                "--config", "Release",
            ],
            capture_and_return_output = true,
        );

        if error {
            return error;
        }

        if result.exit_code != 0 {
            return "Failed to install SDL";
        }
    }

    { // Install SDL
        result, _, error, _ := run_command(
            ..string.["cmake", "--install", absolute_artefact_path, "--config", "Release"],
            capture_and_return_output = true,
        );

        if error {
            return error;
        }

        if result.exit_code != 0 {
            return "Failed to install SDL";
        }
    }

    { // Delete stuff
        delete_directory(tprint("%/include", absolute_install_path));
        delete_directory(tprint("%/lib/cmake", absolute_install_path));
        delete_directory(tprint("%/lib/pkgconfig", absolute_install_path));
    }

    return "";
}
