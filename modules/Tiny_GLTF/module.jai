#module_parameters()(DEBUG := false);

#if OS == .LINUX {
    #if DEBUG {
        tinygltf :: #library,no_dll "./LINUX/tinygltf_debug";
    } else {
        tinygltf :: #library,no_dll "./LINUX/tinygltf";
    }
}
