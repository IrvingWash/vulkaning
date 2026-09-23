#version 460

#extension GL_EXT_nonuniform_qualifier : require

layout(location = 0) in vec3 in_color;
layout(location = 1) in vec3 in_normal;
layout(location = 2) in vec2 in_uv;
layout(location = 3) in flat uint in_texture_index;
layout(location = 4) in flat vec4 in_material_base_color;

layout(location = 0) out vec4 fragment_color;

layout(set = 0, binding = 0) uniform sampler2D textures[];

void main() {
    vec4 texture_color = texture(textures[in_texture_index], in_uv);

    vec3 n_normal = normalize(in_normal);
    vec3 light_direction = normalize(vec3(0, -1, -1));
    float light_alignment = max(dot(n_normal, -light_direction), 0);

    vec3 sky_color    = vec3(0.15, 0.18, 0.25);
    vec3 ground_color = vec3(0.05, 0.03, 0.02);
    float t = n_normal.y * 0.5 + 0.5;
    vec3 hemi_ambient = mix(ground_color, sky_color, t);

    vec3 final_color = in_color * texture_color.rgb * in_material_base_color.rgb;
    vec3 lit_color = final_color * light_alignment + final_color * hemi_ambient;

    fragment_color = vec4(lit_color, texture_color.a);
}
