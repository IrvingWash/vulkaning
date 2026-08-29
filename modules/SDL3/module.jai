SDL_Window_Flags :: enum_flags u64 {
    VULKAN    :: 0x0000000010000000;
    RESIZABLE :: 0x0000000000000020;
}

#if OS == {
    case .LINUX;
        #load "linux.jai";
        libsdl3 :: #library "./LINUX/lib/libSDL3";
    case;
        #assert "Unsupported OS";
}
