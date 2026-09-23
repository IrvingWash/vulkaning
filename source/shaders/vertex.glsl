#version 460

#extension GL_EXT_buffer_reference                       : require
#extension GL_EXT_scalar_block_layout                    : require
#extension GL_EXT_shader_explicit_arithmetic_types_int64 : require

layout(push_constant, scalar) uniform Frame_Constants {
    uint64_t vertex_buffer_address;
    uint64_t material_buffer_address;
    uint64_t render_item_buffer_address;
} frame_constants;

struct Vertex {
    vec3 position;
    vec3 color;
    vec3 normal;
    vec2 uv;
};

layout(buffer_reference, scalar) readonly buffer Vertex_Pointer {
    Vertex vertices[];
};

struct Material {
    vec4 base_color;
    uint color_texture_index;
};

layout(buffer_reference, scalar) readonly buffer Material_Pointer {
    Material materials[];
};

struct Render_Item {
    mat4x4 wvp;
    mat4x4 world_matrix;
    uint   material_index;
};

layout(buffer_reference, scalar) readonly buffer Render_Item_Pointer {
    Render_Item render_items[];
};

layout(location = 0) out vec3 out_color;
layout(location = 1) out vec3 out_normal;
layout(location = 2) out vec2 out_uv;
layout(location = 3) out flat uint out_texture_index;
layout(location = 4) out flat vec4 out_material_base_color;

void main() {
    Vertex_Pointer vertex_buffer = Vertex_Pointer(frame_constants.vertex_buffer_address);
    Vertex vertex = vertex_buffer.vertices[gl_VertexIndex];

    Render_Item_Pointer render_item_buffer = Render_Item_Pointer(frame_constants.render_item_buffer_address);
    Render_Item render_item = render_item_buffer.render_items[gl_InstanceIndex];

    Material_Pointer material_buffer = Material_Pointer(frame_constants.material_buffer_address);
    Material material = material_buffer.materials[render_item.material_index];

    gl_Position = render_item.wvp * vec4(vertex.position, 1);
    out_color               = vertex.color;
    out_normal              = mat3x3(transpose(inverse(render_item.world_matrix))) * vertex.normal;
    out_uv                  = vertex.uv;
    out_texture_index       = material.color_texture_index;
    out_material_base_color = material.base_color;
}
