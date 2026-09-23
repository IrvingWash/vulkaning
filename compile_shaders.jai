compile_shaders :: (optimization_type: Optimization_Type) -> error: string {
    output_path := tprint("%/%/shaders", SHADERS_OUTPUT_PATH_BASE, optimization_type);

    ok := make_directory_if_it_does_not_exist(output_path, recursive = true);
    if !ok {
        return tprint("Failed to create directory at %", output_path);
    }

    for shader: SHADERS {
        command: [..]string;
        command.allocator = temp;

        array_add(
            *command,
            "glslc",
            "--target-env=vulkan1.4",
            "--target-spv=spv1.6",
        );

        if optimization_type < .OPTIMIZED {
            array_add(
                *command,
                "-g",
                "-O0",
                "-Werror",
            );
        } else {
            array_add(
                *command,
                "-O",
            );
        }

        array_add(
            *command,
            tprint("-fshader-stage=%", get_stage_name(shader.stage)),
            tprint("%/%", SHADERS_SOURCE_PATH, shader.original_name),
            "-o",
            tprint("%/%/shaders/%", SHADERS_OUTPUT_PATH_BASE, optimization_type, shader.compiled_name),
        );

        result, _, error := run_command(
            ..command,
            capture_and_return_output = true,
        );
        if error {
            return error;
        }
    }

    return "";
}



#scope_file

SHADERS_SOURCE_PATH      :: #run tprint("%source/shaders", #filepath);
SHADERS_OUTPUT_PATH_BASE :: #run tprint("%bin",            #filepath);

Shader :: struct {
    original_name: string;
    compiled_name: string;
    stage:         Shader_Stage;
}

Shader_Stage :: enum {
    VERTEX;
    FRAGMENT;
}

get_stage_name :: (stage: Shader_Stage) -> string {
    if #complete stage == {
        case .VERTEX;
            return "vertex";
        case .FRAGMENT;
            return "fragment";
    }
}

SHADERS :: Shader.[
    {
        original_name = "vertex.glsl",
        compiled_name = "vertex.spv",
        stage         = .VERTEX,
    },
    {
        original_name = "fragment.glsl",
        compiled_name = "fragment.spv",
        stage         = .FRAGMENT,
    }
];

#import "Basic";
#import "Process";
#import "Compiler";
#import "File";
