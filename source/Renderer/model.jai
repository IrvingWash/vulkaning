Model :: struct {
    vertices: [..]Vertex;
    indices:  [..]u32;
    textures: [..]Texture;

    allocator: Allocator;
}

Vertex :: struct {
    position: Vector3;
    color:    Vector3;
    normal:   Vector3;
    uv:       Vector2;
}

Image :: struct {
    width:         int;
    height:        int;
    channel_count: int;
    data:          *u8;
}

Texture :: struct {
    image_id:   u32;
    sampler_id: u32;
}
