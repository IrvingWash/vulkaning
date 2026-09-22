Node :: struct {
    translation: Vector3;
    scale:       Vector3 = { 1, 1, 1 };
    rotation:     Quaternion;
    transform:   Matrix4 = Matrix4_Identity;

    mesh_id:         u32;
    parent_id:       u32;
    next_sibling_id: u32;
    first_child_id:  u32;

    dirty: bool = true;
}

Mesh :: struct {
    name:       string;
    sub_meshes: [..]Sub_Mesh;
}

Sub_Mesh :: struct {
    vertex_start: u64;
    vertex_count: u64;
    index_start:  u64;
    index_count:  u64;

    material_id: u32;
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

Material :: struct {
    base_color: Vector4 = { 1, 1, 1, 1 };
    texture_id: u32;
}

Vertex :: struct {
    position: Vector3;
    color:    Vector3 = { 1, 1, 1 };
    normal:   Vector3;
    uv:       Vector2;
}

make_transformation_matrix :: (node: *Node) {
    if !node.dirty return;

    translation := make_translation_matrix4(node.translation);
    rotation    := rotation_matrix(Matrix4, node.rotation);
    scaling     := make_scale_matrix4(node.scale);

    node.transform = translation * rotation * scaling;
    node.dirty = false;
}

destroy_mesh :: (mesh: *Mesh) {
    free(mesh.name);
    array_free(mesh.sub_meshes);

    mesh.* = {};
}
