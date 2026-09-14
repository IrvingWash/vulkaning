//
// This file was auto-generated using the following command:
//
// jai ./modules/Tiny_GLTF/generate.jai
//



TINYGLTF3_MAX_MEMORY_BYTES :: 1 << 30;

TINYGLTF3_MAX_NESTING_DEPTH :: 512;

TINYGLTF3_MAX_STRING_LENGTH :: 64 * 1024 * 1024;

TG3_MODE_POINTS :: 0;
TG3_MODE_LINE :: 1;
TG3_MODE_LINE_LOOP :: 2;
TG3_MODE_LINE_STRIP :: 3;
TG3_MODE_TRIANGLES :: 4;
TG3_MODE_TRIANGLE_STRIP :: 5;
TG3_MODE_TRIANGLE_FAN :: 6;

TG3_COMPONENT_TYPE_BYTE :: 5120;
TG3_COMPONENT_TYPE_UNSIGNED_BYTE :: 5121;
TG3_COMPONENT_TYPE_SHORT :: 5122;
TG3_COMPONENT_TYPE_UNSIGNED_SHORT :: 5123;
TG3_COMPONENT_TYPE_INT :: 5124;
TG3_COMPONENT_TYPE_UNSIGNED_INT :: 5125;
TG3_COMPONENT_TYPE_FLOAT :: 5126;
TG3_COMPONENT_TYPE_DOUBLE :: 5130;

TG3_TYPE_VEC2 :: 2;
TG3_TYPE_VEC3 :: 3;
TG3_TYPE_VEC4 :: 4;
TG3_TYPE_MAT2 :: 32 + 2;
TG3_TYPE_MAT3 :: 32 + 3;
TG3_TYPE_MAT4 :: 32 + 4;
TG3_TYPE_SCALAR :: 64 + 1;
TG3_TYPE_VECTOR :: 64 + 4;
TG3_TYPE_MATRIX :: 64 + 16;

TG3_TEXTURE_FILTER_NEAREST :: 9728;
TG3_TEXTURE_FILTER_LINEAR :: 9729;
TG3_TEXTURE_FILTER_NEAREST_MIPMAP_NEAREST :: 9984;
TG3_TEXTURE_FILTER_LINEAR_MIPMAP_NEAREST :: 9985;
TG3_TEXTURE_FILTER_NEAREST_MIPMAP_LINEAR :: 9986;
TG3_TEXTURE_FILTER_LINEAR_MIPMAP_LINEAR :: 9987;

TG3_TEXTURE_WRAP_REPEAT :: 10497;
TG3_TEXTURE_WRAP_CLAMP_TO_EDGE :: 33071;
TG3_TEXTURE_WRAP_MIRRORED_REPEAT :: 33648;

TG3_IMAGE_FORMAT_JPEG :: 0;
TG3_IMAGE_FORMAT_PNG :: 1;
TG3_IMAGE_FORMAT_BMP :: 2;
TG3_IMAGE_FORMAT_GIF :: 3;

TG3_TEXTURE_FORMAT_ALPHA :: 6406;
TG3_TEXTURE_FORMAT_RGB :: 6407;
TG3_TEXTURE_FORMAT_RGBA :: 6408;
TG3_TEXTURE_FORMAT_LUMINANCE :: 6409;
TG3_TEXTURE_FORMAT_LUMINANCE_ALPHA :: 6410;

TG3_TEXTURE_TARGET_TEXTURE2D :: 3553;
TG3_TEXTURE_TYPE_UNSIGNED_BYTE :: 5121;

TG3_TARGET_ARRAY_BUFFER :: 34962;
TG3_TARGET_ELEMENT_ARRAY_BUFFER :: 34963;

TG3_INDEX_NONE :: -1;

TG3_NO_REQUIRE :: 0x00;
TG3_REQUIRE_VERSION :: 0x01;
TG3_REQUIRE_SCENE :: 0x02;
TG3_REQUIRE_SCENES :: 0x04;
TG3_REQUIRE_NODES :: 0x08;
TG3_REQUIRE_ACCESSORS :: 0x10;
TG3_REQUIRE_BUFFERS :: 0x20;
TG3_REQUIRE_BUFFER_VIEWS :: 0x40;
TG3_REQUIRE_ALL :: 0x7f;

/* Parse strictness */
tg3_strictness :: enum u32 {
    PERMISSIVE :: 0;
    STRICT     :: 1;

    TG3_PERMISSIVE :: PERMISSIVE;
    TG3_STRICT     :: STRICT;
}

/* ======================================================================
* Section 5: Foundation Types
* ====================================================================== */
tg3_str :: struct {
    data: *u8;
    len:  u32;
}

tg3_span_i32 :: struct {
    data:  *s32;
    count: u32;
}

tg3_span_f64 :: struct {
    data:  *float64;
    count: u32;
}

tg3_span_u8 :: struct {
    data:  *u8;
    count: u64;
}

tg3_str_int_pair :: struct {
    key:   tg3_str;
    value: s32;
}

/* ======================================================================
* Section 6: Allocator Interface
* ====================================================================== */
tg3_allocator :: struct {
    alloc:     #type (size: u64, user_data: *void) -> *void #c_call;
    realloc:   #type (ptr: *void, old_size: u64, new_size: u64, user_data: *void) -> *void #c_call;
    free:      #type (ptr: *void, size: u64, user_data: *void) -> void #c_call;
    user_data: *void;
}

/* ======================================================================
* Section 7: Error Reporting
* ====================================================================== */
tg3_severity :: enum u32 {
    INFO    :: 0;
    WARNING :: 1;
    ERROR   :: 2;

    TG3_SEVERITY_INFO    :: INFO;
    TG3_SEVERITY_WARNING :: WARNING;
    TG3_SEVERITY_ERROR   :: ERROR;
}

tg3_error_code :: enum u32 {
    OK                       :: 0;

    ERR_FILE_NOT_FOUND       :: 1;
    ERR_FILE_READ            :: 2;
    ERR_FILE_WRITE           :: 3;
    ERR_FILE_TOO_LARGE       :: 4;

    ERR_JSON_PARSE           :: 10;
    ERR_JSON_TYPE_MISMATCH   :: 11;
    ERR_JSON_MISSING_FIELD   :: 12;
    ERR_JSON_INVALID_VALUE   :: 13;

    ERR_GLB_INVALID_MAGIC    :: 20;
    ERR_GLB_INVALID_VERSION  :: 21;
    ERR_GLB_INVALID_HEADER   :: 22;
    ERR_GLB_CHUNK_ERROR      :: 23;
    ERR_GLB_SIZE_MISMATCH    :: 24;

    ERR_MISSING_REQUIRED     :: 30;
    ERR_INVALID_INDEX        :: 31;
    ERR_INVALID_TYPE         :: 32;
    ERR_INVALID_VALUE        :: 33;
    ERR_INVALID_ACCESSOR     :: 34;
    ERR_INVALID_BUFFER       :: 35;
    ERR_INVALID_BUFFER_VIEW  :: 36;
    ERR_INVALID_IMAGE        :: 37;
    ERR_INVALID_MATERIAL     :: 38;
    ERR_INVALID_MESH         :: 39;
    ERR_INVALID_NODE         :: 40;
    ERR_INVALID_ANIMATION    :: 41;
    ERR_INVALID_SKIN         :: 42;
    ERR_INVALID_CAMERA       :: 43;
    ERR_INVALID_SCENE        :: 44;
    ERR_BUFFER_SIZE_MISMATCH :: 45;

    ERR_OUT_OF_MEMORY        :: 50;
    ERR_DATA_URI_DECODE      :: 51;
    ERR_BASE64_DECODE        :: 52;
    ERR_EXTERNAL_RESOURCE    :: 53;
    ERR_IMAGE_DECODE         :: 54;

    ERR_CALLBACK_FAILED      :: 60;
    ERR_FS_NOT_AVAILABLE     :: 61;

    ERR_STREAM_ABORTED       :: 70;

    ERR_WRITE_FAILED         :: 80;
    ERR_SERIALIZE_FAILED     :: 81;

    TG3_OK                       :: OK;

    TG3_ERR_FILE_NOT_FOUND       :: ERR_FILE_NOT_FOUND;
    TG3_ERR_FILE_READ            :: ERR_FILE_READ;
    TG3_ERR_FILE_WRITE           :: ERR_FILE_WRITE;
    TG3_ERR_FILE_TOO_LARGE       :: ERR_FILE_TOO_LARGE;

    TG3_ERR_JSON_PARSE           :: ERR_JSON_PARSE;
    TG3_ERR_JSON_TYPE_MISMATCH   :: ERR_JSON_TYPE_MISMATCH;
    TG3_ERR_JSON_MISSING_FIELD   :: ERR_JSON_MISSING_FIELD;
    TG3_ERR_JSON_INVALID_VALUE   :: ERR_JSON_INVALID_VALUE;

    TG3_ERR_GLB_INVALID_MAGIC    :: ERR_GLB_INVALID_MAGIC;
    TG3_ERR_GLB_INVALID_VERSION  :: ERR_GLB_INVALID_VERSION;
    TG3_ERR_GLB_INVALID_HEADER   :: ERR_GLB_INVALID_HEADER;
    TG3_ERR_GLB_CHUNK_ERROR      :: ERR_GLB_CHUNK_ERROR;
    TG3_ERR_GLB_SIZE_MISMATCH    :: ERR_GLB_SIZE_MISMATCH;

    TG3_ERR_MISSING_REQUIRED     :: ERR_MISSING_REQUIRED;
    TG3_ERR_INVALID_INDEX        :: ERR_INVALID_INDEX;
    TG3_ERR_INVALID_TYPE         :: ERR_INVALID_TYPE;
    TG3_ERR_INVALID_VALUE        :: ERR_INVALID_VALUE;
    TG3_ERR_INVALID_ACCESSOR     :: ERR_INVALID_ACCESSOR;
    TG3_ERR_INVALID_BUFFER       :: ERR_INVALID_BUFFER;
    TG3_ERR_INVALID_BUFFER_VIEW  :: ERR_INVALID_BUFFER_VIEW;
    TG3_ERR_INVALID_IMAGE        :: ERR_INVALID_IMAGE;
    TG3_ERR_INVALID_MATERIAL     :: ERR_INVALID_MATERIAL;
    TG3_ERR_INVALID_MESH         :: ERR_INVALID_MESH;
    TG3_ERR_INVALID_NODE         :: ERR_INVALID_NODE;
    TG3_ERR_INVALID_ANIMATION    :: ERR_INVALID_ANIMATION;
    TG3_ERR_INVALID_SKIN         :: ERR_INVALID_SKIN;
    TG3_ERR_INVALID_CAMERA       :: ERR_INVALID_CAMERA;
    TG3_ERR_INVALID_SCENE        :: ERR_INVALID_SCENE;
    TG3_ERR_BUFFER_SIZE_MISMATCH :: ERR_BUFFER_SIZE_MISMATCH;

    TG3_ERR_OUT_OF_MEMORY        :: ERR_OUT_OF_MEMORY;
    TG3_ERR_DATA_URI_DECODE      :: ERR_DATA_URI_DECODE;
    TG3_ERR_BASE64_DECODE        :: ERR_BASE64_DECODE;
    TG3_ERR_EXTERNAL_RESOURCE    :: ERR_EXTERNAL_RESOURCE;
    TG3_ERR_IMAGE_DECODE         :: ERR_IMAGE_DECODE;

    TG3_ERR_CALLBACK_FAILED      :: ERR_CALLBACK_FAILED;
    TG3_ERR_FS_NOT_AVAILABLE     :: ERR_FS_NOT_AVAILABLE;

    TG3_ERR_STREAM_ABORTED       :: ERR_STREAM_ABORTED;

    TG3_ERR_WRITE_FAILED         :: ERR_WRITE_FAILED;
    TG3_ERR_SERIALIZE_FAILED     :: ERR_SERIALIZE_FAILED;
}

tg3_error_entry :: struct {
    severity:    tg3_severity;
    code:        tg3_error_code;
    message:     *u8; /* Arena-owned, null-terminated */
    json_path:   *u8; /* e.g. "/meshes/0/primitives/1" or NULL */
    byte_offset: s64; /* -1 if unknown */
}

tg3_error_stack :: struct {
    entries:   *tg3_error_entry;
    count:     u32;
    capacity:  u32;
    has_error: s32; /* 1 if any entry with severity == ERROR */
}

/* Error stack query functions */
tg3_errors_has_error :: (es: *tg3_error_stack) -> s32 #foreign tinygltf;
tg3_errors_count :: (es: *tg3_error_stack) -> u32 #foreign tinygltf;
tg3_errors_get :: (es: *tg3_error_stack, index: u32) -> *tg3_error_entry #foreign tinygltf;

/* ======================================================================
* Section 8: Generic Value Type (for extras/extensions)
* ====================================================================== */
tg3_value_type :: enum u32 {
    NULL   :: 0;
    BOOL   :: 1;
    INT    :: 2;
    REAL   :: 3;
    STRING :: 4;
    ARRAY  :: 5;
    BINARY :: 6;
    OBJECT :: 7;

    TG3_VALUE_NULL   :: NULL;
    TG3_VALUE_BOOL   :: BOOL;
    TG3_VALUE_INT    :: INT;
    TG3_VALUE_REAL   :: REAL;
    TG3_VALUE_STRING :: STRING;
    TG3_VALUE_ARRAY  :: ARRAY;
    TG3_VALUE_BINARY :: BINARY;
    TG3_VALUE_OBJECT :: OBJECT;
}

tg3_value :: struct {
    type:         tg3_value_type;
    struct {
        int_val: s64; // largest member, moved to the start of the struct/union to support #overlay.

        #overlay (int_val) bool_val: s32;
        #overlay (int_val) real_val: float64;
    }

    string_val:   tg3_str;
    array_data:   *tg3_value;
    array_count:  u32;
    object_data:  *tg3_kv_pair;
    object_count: u32;
    binary_val:   tg3_span_u8;
}

tg3_kv_pair :: struct {
    key:   tg3_str;
    value: tg3_value;
}

tg3_extension :: struct {
    name:  tg3_str;
    value: tg3_value;
}

tg3_extras_ext :: struct {
    extras:           *tg3_value; /* NULL if absent */
    extensions:       *tg3_extension; /* Array */
    extensions_count: u32;
    extras_json:      tg3_str; /* Raw JSON if store_original_json */
    extensions_json:  tg3_str;
}

/* --- Asset --- */
tg3_asset :: struct {
    version:     tg3_str; /* Required, e.g. "2.0" */
    generator:   tg3_str;
    min_version: tg3_str;
    copyright:   tg3_str;
    ext:         tg3_extras_ext;
}

/* --- Buffer --- */
tg3_buffer :: struct {
    name:        tg3_str;
    byte_length: u64; /* Declared buffer.byteLength */
    data:        tg3_span_u8;
    uri:         tg3_str;
    ext:         tg3_extras_ext;
}

/* --- BufferView --- */
tg3_buffer_view :: struct {
    name:          tg3_str;
    buffer:        s32; /* Index, required */
    byte_offset:   u64;
    byte_length:   u64; /* Required */
    byte_stride:   u32; /* 0 = tightly packed */
    target:        s32; /* 0 = unspecified */
    draco_decoded: s32;
    ext:           tg3_extras_ext;
}

/* --- Accessor Sparse --- */
tg3_accessor_sparse_indices :: struct {
    byte_offset:    u64;
    buffer_view:    s32; /* Required */
    component_type: s32; /* Required */
    ext:            tg3_extras_ext;
}

tg3_accessor_sparse_values :: struct {
    buffer_view: s32; /* Required */
    byte_offset: u64;
    ext:         tg3_extras_ext;
}

tg3_accessor_sparse :: struct {
    count:     s32; /* Required if sparse */
    is_sparse: s32; /* 0 or 1 */
    indices:   tg3_accessor_sparse_indices;
    values:    tg3_accessor_sparse_values;
    ext:       tg3_extras_ext;
}

/* --- Accessor --- */
tg3_accessor :: struct {
    name:             tg3_str;
    buffer_view:      s32; /* -1 if absent */
    byte_offset:      u64;
    normalized:       s32; /* 0 or 1 */
    component_type:   s32; /* Required */
    count:            u64; /* Required */
    type:             s32; /* Required: TG3_TYPE_* */
    min_values:       *float64;
    min_values_count: u32;
    max_values:       *float64;
    max_values_count: u32;
    sparse:           tg3_accessor_sparse;
    ext:              tg3_extras_ext;
}

/* --- Image --- */
tg3_image :: struct {
    name:        tg3_str;
    width:       s32;
    height:      s32;
    component:   s32; /* Channels */
    bits:        s32; /* Bits per channel */
    pixel_type:  s32; /* Component type */
    image:       tg3_span_u8; /* Decoded pixel data (or raw if as_is) */
    buffer_view: s32; /* -1 if absent */
    mime_type:   tg3_str;
    uri:         tg3_str;
    as_is:       s32;
    ext:         tg3_extras_ext;
}

/* --- Sampler --- */
tg3_sampler :: struct {
    name:       tg3_str;
    min_filter: s32; /* -1 = unspecified */
    mag_filter: s32; /* -1 = unspecified */
    wrap_s:     s32; /* Default: TG3_TEXTURE_WRAP_REPEAT */
    wrap_t:     s32; /* Default: TG3_TEXTURE_WRAP_REPEAT */
    ext:        tg3_extras_ext;
}

/* --- Texture --- */
tg3_texture :: struct {
    name:    tg3_str;
    sampler: s32; /* -1 if absent */
    source:  s32; /* -1 if absent */
    ext:     tg3_extras_ext;
}

/* --- TextureInfo --- */
tg3_texture_info :: struct {
    index:     s32; /* -1 if absent */
    tex_coord: s32; /* Default: 0 */
    ext:       tg3_extras_ext;
}

/* --- NormalTextureInfo --- */
tg3_normal_texture_info :: struct {
    index:     s32;
    tex_coord: s32;
    scale:     float64; /* Default: 1.0 */
    ext:       tg3_extras_ext;
}

/* --- OcclusionTextureInfo --- */
tg3_occlusion_texture_info :: struct {
    index:     s32;
    tex_coord: s32;
    strength:  float64; /* Default: 1.0 */
    ext:       tg3_extras_ext;
}

/* --- PBR Metallic Roughness --- */
tg3_pbr_metallic_roughness :: struct {
    base_color_factor:          [4] float64; /* Default: {1,1,1,1} */
    base_color_texture:         tg3_texture_info;
    metallic_factor:            float64; /* Default: 1.0 */
    roughness_factor:           float64; /* Default: 1.0 */
    metallic_roughness_texture: tg3_texture_info;
    ext:                        tg3_extras_ext;
}

/* --- Material --- */
tg3_material :: struct {
    name:                   tg3_str;
    emissive_factor:        [3] float64; /* Default: {0,0,0} */
    alpha_mode:             tg3_str; /* "OPAQUE","MASK","BLEND" */
    alpha_cutoff:           float64; /* Default: 0.5 */
    double_sided:           s32; /* 0 or 1 */
    lods:                   *s32;
    lods_count:             u32;
    pbr_metallic_roughness: tg3_pbr_metallic_roughness;
    normal_texture:         tg3_normal_texture_info;
    occlusion_texture:      tg3_occlusion_texture_info;
    emissive_texture:       tg3_texture_info;
    ext:                    tg3_extras_ext;
}

/* --- Primitive --- */
tg3_primitive :: struct {
    attributes:              *tg3_str_int_pair;
    attributes_count:        u32;
    material:                s32; /* -1 if absent */
    indices:                 s32; /* -1 if absent */
    mode:                    s32; /* -1 = default (TRIANGLES) */

    /* Morph targets: array of arrays of attribute pairs */
    targets:                 **tg3_str_int_pair;
    target_attribute_counts: *u32;
    targets_count:           u32;

    ext:                     tg3_extras_ext;
}

/* --- Mesh --- */
tg3_mesh :: struct {
    name:             tg3_str;
    primitives:       *tg3_primitive;
    primitives_count: u32;
    weights:          *float64;
    weights_count:    u32;
    ext:              tg3_extras_ext;
}

/* --- Node --- */
tg3_node :: struct {
    name:           tg3_str;
    camera:         s32; /* -1 if absent */
    skin:           s32; /* -1 if absent */
    mesh:           s32; /* -1 if absent */
    light:          s32; /* -1 if absent (KHR_lights_punctual) */
    emitter:        s32; /* -1 if absent (KHR_audio) */

    lods:           *s32;
    lods_count:     u32;
    children:       *s32;
    children_count: u32;

    rotation:       [4] float64; /* Default: {0,0,0,1} */
    scale:          [3] float64; /* Default: {1,1,1} */
    translation:    [3] float64; /* Default: {0,0,0} */
    matrix:         [16] float64; /* Identity if not set */
    has_matrix:     s32; /* 1 if matrix was specified */

    weights:        *float64;
    weights_count:  u32;

    ext:            tg3_extras_ext;
}

/* --- Skin --- */
tg3_skin :: struct {
    name:                  tg3_str;
    inverse_bind_matrices: s32; /* -1 if absent */
    skeleton:              s32; /* -1 if absent */
    joints:                *s32;
    joints_count:          u32;
    ext:                   tg3_extras_ext;
}

/* --- Animation --- */
tg3_animation_channel_target :: struct {
    node: s32; /* -1 if absent */
    path: tg3_str; /* "translation","rotation","scale","weights" */
    ext:  tg3_extras_ext;
}

tg3_animation_channel :: struct {
    sampler: s32; /* Required */
    target:  tg3_animation_channel_target;
    ext:     tg3_extras_ext;
}

tg3_animation_sampler :: struct {
    input:         s32; /* Required */
    output:        s32; /* Required */
    interpolation: tg3_str; /* "LINEAR","STEP","CUBICSPLINE" */
    ext:           tg3_extras_ext;
}

tg3_animation :: struct {
    name:           tg3_str;
    channels:       *tg3_animation_channel;
    channels_count: u32;
    samplers:       *tg3_animation_sampler;
    samplers_count: u32;
    ext:            tg3_extras_ext;
}

/* --- Camera --- */
tg3_perspective_camera :: struct {
    aspect_ratio: float64;
    yfov:         float64;
    zfar:         float64; /* 0 = infinite */
    znear:        float64;
    ext:          tg3_extras_ext;
}

tg3_orthographic_camera :: struct {
    xmag:  float64;
    ymag:  float64;
    zfar:  float64;
    znear: float64;
    ext:   tg3_extras_ext;
}

tg3_camera :: struct {
    name:         tg3_str;
    type:         tg3_str; /* "perspective" or "orthographic" */
    perspective:  tg3_perspective_camera;
    orthographic: tg3_orthographic_camera;
    ext:          tg3_extras_ext;
}

/* --- Scene --- */
tg3_scene :: struct {
    name:                 tg3_str;
    nodes:                *s32;
    nodes_count:          u32;
    audio_emitters:       *s32;
    audio_emitters_count: u32;
    ext:                  tg3_extras_ext;
}

/* --- Light (KHR_lights_punctual) --- */
tg3_spot_light :: struct {
    inner_cone_angle: float64; /* Default: 0 */
    outer_cone_angle: float64; /* Default: PI/4 */
    ext:              tg3_extras_ext;
}

tg3_light :: struct {
    name:      tg3_str;
    color:     [3] float64; /* Default: {1,1,1} */
    intensity: float64; /* Default: 1.0 */
    type:      tg3_str; /* "directional","point","spot" */
    range:     float64; /* Default: 0 (infinite) */
    spot:      tg3_spot_light;
    ext:       tg3_extras_ext;
}

/* --- Audio (KHR_audio) --- */
tg3_audio_source :: struct {
    name:        tg3_str;
    uri:         tg3_str;
    buffer_view: s32; /* -1 if absent */
    mime_type:   tg3_str;
    ext:         tg3_extras_ext;
}

tg3_positional_emitter :: struct {
    cone_inner_angle: float64; /* Default: 2*PI */
    cone_outer_angle: float64; /* Default: 2*PI */
    cone_outer_gain:  float64; /* Default: 0 */
    max_distance:     float64; /* Default: 100 */
    ref_distance:     float64; /* Default: 1 */
    rolloff_factor:   float64; /* Default: 1 */
    ext:              tg3_extras_ext;
}

tg3_audio_emitter :: struct {
    name:           tg3_str;
    gain:           float64; /* Default: 1.0 */
    loop:           s32; /* Default: 0 */
    playing:        s32; /* Default: 0 */
    type:           tg3_str; /* "positional" or "global" */
    distance_model: tg3_str; /* "linear","inverse","exponential" */
    positional:     tg3_positional_emitter;
    source:         s32; /* -1 if absent */
    ext:            tg3_extras_ext;
}

/* Opaque arena type */
tg3_arena :: struct {}

tg3_model :: struct {
    arena_:                    *tg3_arena; /* Internal, all memory owned here */

    accessors:                 *tg3_accessor;
    accessors_count:           u32;
    animations:                *tg3_animation;
    animations_count:          u32;
    buffers:                   *tg3_buffer;
    buffers_count:             u32;
    buffer_views:              *tg3_buffer_view;
    buffer_views_count:        u32;
    materials:                 *tg3_material;
    materials_count:           u32;
    meshes:                    *tg3_mesh;
    meshes_count:              u32;
    nodes:                     *tg3_node;
    nodes_count:               u32;
    textures:                  *tg3_texture;
    textures_count:            u32;
    images:                    *tg3_image;
    images_count:              u32;
    skins:                     *tg3_skin;
    skins_count:               u32;
    samplers:                  *tg3_sampler;
    samplers_count:            u32;
    cameras:                   *tg3_camera;
    cameras_count:             u32;
    scenes:                    *tg3_scene;
    scenes_count:              u32;
    lights:                    *tg3_light;
    lights_count:              u32;
    audio_emitters:            *tg3_audio_emitter;
    audio_emitters_count:      u32;
    audio_sources:             *tg3_audio_source;
    audio_sources_count:       u32;

    default_scene:             s32;
    extensions_used:           *tg3_str;
    extensions_used_count:     u32;
    extensions_required:       *tg3_str;
    extensions_required_count: u32;
    asset:                     tg3_asset;
    ext:                       tg3_extras_ext;
}

/* --- Filesystem Callbacks --- */
tg3_file_exists_fn :: #type (path: *u8, path_len: u32, user_data: *void) -> s32 #c_call;

tg3_read_file_fn :: #type (out_data: **u8, out_size: *u64, path: *u8, path_len: u32, user_data: *void) -> s32 #c_call;

tg3_free_file_fn :: #type (data: *u8, size: u64, user_data: *void) -> void #c_call;

tg3_write_file_fn :: #type (path: *u8, path_len: u32, data: *u8, size: u64, user_data: *void) -> s32 #c_call;

tg3_resolve_path_fn :: #type (out_path: *u8, out_cap: u32, out_len: *u32, path: *u8, path_len: u32, user_data: *void) -> s32 #c_call;

tg3_get_file_size_fn :: #type (out_size: *u64, path: *u8, path_len: u32, user_data: *void) -> s32 #c_call;

tg3_fs_callbacks :: struct {
    file_exists:   tg3_file_exists_fn;
    read_file:     tg3_read_file_fn;
    free_file:     tg3_free_file_fn;
    write_file:    tg3_write_file_fn;
    resolve_path:  tg3_resolve_path_fn;
    get_file_size: tg3_get_file_size_fn;
    user_data:     *void;
}

/* --- Image Callbacks --- */
tg3_image_request :: struct {
    data:        *u8;
    data_size:   u64;
    image_index: s32;
    req_width:   s32;
    req_height:  s32;
    mime_type:   *u8;
}

tg3_image_result :: struct {
    pixels:     *u8; /* Caller must allocate */
    width:      s32;
    height:     s32;
    component:  s32;
    bits:       s32;
    pixel_type: s32;
}

tg3_load_image_fn :: #type (result: *tg3_image_result, request: *tg3_image_request, user_data: *void) -> s32 #c_call;

tg3_free_image_fn :: #type (pixels: *u8, user_data: *void) -> void #c_call;

tg3_image_callbacks :: struct {
    load_image: tg3_load_image_fn;
    free_image: tg3_free_image_fn;
    user_data:  *void;
}

/* --- URI Callbacks --- */
tg3_uri_encode_fn :: #type (out: *u8, out_cap: u32, out_len: *u32, uri: *u8, uri_len: u32, obj_type: *u8, user_data: *void) -> s32 #c_call;

tg3_uri_decode_fn :: #type (out: *u8, out_cap: u32, out_len: *u32, uri: *u8, uri_len: u32, user_data: *void) -> s32 #c_call;

tg3_uri_callbacks :: struct {
    encode:    tg3_uri_encode_fn;
    decode:    tg3_uri_decode_fn;
    user_data: *void;
}

/* --- Streaming Callbacks --- */
tg3_stream_action :: enum u32 {
    CONTINUE :: 0;
    ABORT    :: 1;
    SKIP     :: 2;

    TG3_STREAM_CONTINUE :: CONTINUE;
    TG3_STREAM_ABORT    :: ABORT;
    TG3_STREAM_SKIP     :: SKIP;
}

tg3_on_asset_fn :: #type (a: *tg3_asset, ud: *void) -> tg3_stream_action #c_call;
tg3_on_buffer_fn :: #type (b: *tg3_buffer, idx: s32, ud: *void) -> tg3_stream_action #c_call;
tg3_on_buffer_view_fn :: #type (bv: *tg3_buffer_view, idx: s32, ud: *void) -> tg3_stream_action #c_call;
tg3_on_accessor_fn :: #type (a: *tg3_accessor, idx: s32, ud: *void) -> tg3_stream_action #c_call;
tg3_on_mesh_fn :: #type (m: *tg3_mesh, idx: s32, ud: *void) -> tg3_stream_action #c_call;
tg3_on_node_fn :: #type (n: *tg3_node, idx: s32, ud: *void) -> tg3_stream_action #c_call;
tg3_on_material_fn :: #type (m: *tg3_material, idx: s32, ud: *void) -> tg3_stream_action #c_call;
tg3_on_texture_fn :: #type (t: *tg3_texture, idx: s32, ud: *void) -> tg3_stream_action #c_call;
tg3_on_image_fn :: #type (img: *tg3_image, idx: s32, ud: *void) -> tg3_stream_action #c_call;
tg3_on_sampler_fn :: #type (s: *tg3_sampler, idx: s32, ud: *void) -> tg3_stream_action #c_call;
tg3_on_animation_fn :: #type (a: *tg3_animation, idx: s32, ud: *void) -> tg3_stream_action #c_call;
tg3_on_skin_fn :: #type (s: *tg3_skin, idx: s32, ud: *void) -> tg3_stream_action #c_call;
tg3_on_camera_fn :: #type (c: *tg3_camera, idx: s32, ud: *void) -> tg3_stream_action #c_call;
tg3_on_scene_fn :: #type (s: *tg3_scene, idx: s32, ud: *void) -> tg3_stream_action #c_call;
tg3_on_light_fn :: #type (l: *tg3_light, idx: s32, ud: *void) -> tg3_stream_action #c_call;

tg3_stream_callbacks :: struct {
    on_asset:       tg3_on_asset_fn;
    on_buffer:      tg3_on_buffer_fn;
    on_buffer_view: tg3_on_buffer_view_fn;
    on_accessor:    tg3_on_accessor_fn;
    on_mesh:        tg3_on_mesh_fn;
    on_node:        tg3_on_node_fn;
    on_material:    tg3_on_material_fn;
    on_texture:     tg3_on_texture_fn;
    on_image:       tg3_on_image_fn;
    on_sampler:     tg3_on_sampler_fn;
    on_animation:   tg3_on_animation_fn;
    on_skin:        tg3_on_skin_fn;
    on_camera:      tg3_on_camera_fn;
    on_scene:       tg3_on_scene_fn;
    on_light:       tg3_on_light_fn;
    user_data:      *void;
}

/* --- Progress Callback --- */
tg3_progress_info :: struct {
    bytes_processed: u64;
    bytes_total:     u64;
    elements_parsed: u32;
    current_section: *u8; /* e.g. "meshes", "nodes" */
}

tg3_progress_fn :: #type (info: *tg3_progress_info, user_data: *void) -> s32 #c_call;

/* --- Write Chunk Callback (for streaming writer) --- */
tg3_write_chunk_fn :: #type (data: *u8, size: u64, user_data: *void) -> s32 #c_call;

/* ======================================================================
* Section 12: Options Structs
* ====================================================================== */
tg3_memory_config :: struct {
    memory_budget:    u64; /* 0 = use TINYGLTF3_MAX_MEMORY_BYTES */
    max_single_alloc: u64; /* 0 = no limit */
    arena_block_size: u32; /* 0 = default (256KB) */
    allocator:        tg3_allocator; /* All zero = use malloc/free */
}

tg3_parse_options :: struct {
    required_sections:       u32; /* TG3_REQUIRE_* flags */
    strictness:              tg3_strictness;
    memory:                  tg3_memory_config;

    fs:                      tg3_fs_callbacks;
    uri:                     tg3_uri_callbacks;
    image:                   tg3_image_callbacks;
    stream:                  *tg3_stream_callbacks; /* NULL = no streaming */
    progress:                tg3_progress_fn;
    progress_user_data:      *void;

    images_as_is:            s32; /* 1 = don't decode images */
    preserve_image_channels: s32; /* 1 = keep original channels */
    store_original_json:     s32; /* 1 = store raw JSON strings */
    /* 1 = skip materializing extras and
    *     unknown extension value trees */
    skip_extras_values:      s32;

    /* 1 = GLB BIN buffer spans may point
    *     into caller-owned input data */
    borrow_input_buffers:    s32;

    /* 1 = parse JSON floats as float32 for speed
    *     (breaks strict double-precision conformance
    *      but sufficient for glTF data which is
    *      typically single-precision anyway) */
    parse_float32:           s32;

    /* 1 = reject out-of-range index fields
    *     after parse so naive consumers cannot
    *     dereference attacker-controlled indices.
    *     Default: 1. Set to 0 to skip (raw mode). */
    validate_indices:        s32;

    max_external_file_size:  u64; /* 0 = no limit */
}

tg3_write_options :: struct {
    pretty_print:       s32; /* 1 = indented JSON */
    write_binary:       s32; /* 1 = GLB format */
    embed_images:       s32; /* 1 = embed as data URIs */
    embed_buffers:      s32; /* 1 = embed as data URIs */
    serialize_defaults: s32; /* 1 = write default values */
    fs:                 tg3_fs_callbacks;
    uri:                tg3_uri_callbacks;
    memory:             tg3_memory_config;
}

/* Parse JSON glTF from memory */
tg3_parse :: (model: *tg3_model, errors: *tg3_error_stack, json_data: *u8, json_size: u64, base_dir: *u8, base_dir_len: u32, options: *tg3_parse_options) -> tg3_error_code #foreign tinygltf;

/* Parse GLB from memory */
tg3_parse_glb :: (model: *tg3_model, errors: *tg3_error_stack, glb_data: *u8, glb_size: u64, base_dir: *u8, base_dir_len: u32, options: *tg3_parse_options) -> tg3_error_code #foreign tinygltf;

/* Auto-detect format (JSON or GLB) and parse */
tg3_parse_auto :: (model: *tg3_model, errors: *tg3_error_stack, data: *u8, size: u64, base_dir: *u8, base_dir_len: u32, options: *tg3_parse_options) -> tg3_error_code #foreign tinygltf;

/* Parse from file (requires fs callbacks or TINYGLTF3_ENABLE_FS) */
tg3_parse_file :: (model: *tg3_model, errors: *tg3_error_stack, filename: *u8, filename_len: u32, options: *tg3_parse_options) -> tg3_error_code #foreign tinygltf;

/* Free model and all arena memory */
tg3_model_free :: (model: *tg3_model) -> void #foreign tinygltf;

/* Initialize options to defaults */
tg3_parse_options_init :: (options: *tg3_parse_options) -> void #foreign tinygltf;
tg3_write_options_init :: (options: *tg3_write_options) -> void #foreign tinygltf;

/* Initialize error stack */
tg3_error_stack_init :: (es: *tg3_error_stack) -> void #foreign tinygltf;
tg3_error_stack_free :: (es: *tg3_error_stack) -> void #foreign tinygltf;

/* Write model to memory buffer */
tg3_write_to_memory :: (model: *tg3_model, errors: *tg3_error_stack, out_data: **u8, out_size: *u64, options: *tg3_write_options) -> tg3_error_code #foreign tinygltf;

/* Write model to file */
tg3_write_to_file :: (model: *tg3_model, errors: *tg3_error_stack, filename: *u8, filename_len: u32, options: *tg3_write_options) -> tg3_error_code #foreign tinygltf;

/* Free memory from tg3_write_to_memory */
tg3_write_free :: (data: *u8, options: *tg3_write_options) -> void #foreign tinygltf;

tg3_writer :: struct {}

tg3_writer_create :: (chunk_fn: tg3_write_chunk_fn, user_data: *void, options: *tg3_write_options) -> *tg3_writer #foreign tinygltf;

tg3_writer_begin :: (w: *tg3_writer, asset: *tg3_asset) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_buffer :: (w: *tg3_writer, buf: *tg3_buffer) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_buffer_view :: (w: *tg3_writer, bv: *tg3_buffer_view) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_accessor :: (w: *tg3_writer, acc: *tg3_accessor) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_mesh :: (w: *tg3_writer, mesh: *tg3_mesh) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_node :: (w: *tg3_writer, node: *tg3_node) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_material :: (w: *tg3_writer, mat: *tg3_material) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_texture :: (w: *tg3_writer, tex: *tg3_texture) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_image :: (w: *tg3_writer, img: *tg3_image) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_sampler :: (w: *tg3_writer, samp: *tg3_sampler) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_animation :: (w: *tg3_writer, anim: *tg3_animation) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_skin :: (w: *tg3_writer, skin: *tg3_skin) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_camera :: (w: *tg3_writer, cam: *tg3_camera) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_scene :: (w: *tg3_writer, scene: *tg3_scene) -> tg3_error_code #foreign tinygltf;
tg3_writer_add_light :: (w: *tg3_writer, light: *tg3_light) -> tg3_error_code #foreign tinygltf;
tg3_writer_end :: (w: *tg3_writer) -> tg3_error_code #foreign tinygltf;
tg3_writer_destroy :: (w: *tg3_writer) -> void #foreign tinygltf;

/* Get component size in bytes */
tg3_component_size :: (component_type: s32) -> s32 #foreign tinygltf;

/* Get number of components for a type */
tg3_num_components :: (type: s32) -> s32 #foreign tinygltf;

/* Compute byte stride for an accessor */
tg3_accessor_byte_stride :: (accessor: *tg3_accessor, buffer_view: *tg3_buffer_view) -> s32 #foreign tinygltf;

/* Check if a string is a data URI */
tg3_is_data_uri :: (uri: *u8, len: u32) -> s32 #foreign tinygltf;

/* tg3_str helpers */
tg3_str_equals :: (a: tg3_str, b: tg3_str) -> s32 #foreign tinygltf;
tg3_str_equals_cstr :: (a: tg3_str, b: *u8) -> s32 #foreign tinygltf;

tg3json_type :: enum u32 {
    NULL   :: 0;
    BOOL   :: 1;
    INT    :: 2;
    REAL   :: 3;
    STRING :: 4;
    ARRAY  :: 5;
    OBJECT :: 6;

    TG3JSON_NULL   :: NULL;
    TG3JSON_BOOL   :: BOOL;
    TG3JSON_INT    :: INT;
    TG3JSON_REAL   :: REAL;
    TG3JSON_STRING :: STRING;
    TG3JSON_ARRAY  :: ARRAY;
    TG3JSON_OBJECT :: OBJECT;
}

tg3json_string :: struct {
    ptr: *u8;
    len: u64;
}

tg3json_array :: struct {
    items: *tg3json_value;
    count: u64;
}

tg3json_object_entry :: struct {
    key:     *u8;
    key_len: u64;
    value:   *tg3json_value;
}

tg3json_object :: struct {
    items: *tg3json_object_entry;
    count: u64;
}

tg3json_value :: struct {
    type: tg3json_type;
    u:    struct {
        _string: tg3json_string; // largest member, moved to the start of the struct/union to support #overlay.

        #overlay (_string) boolean: s32;
        #overlay (_string) integer: s64;
        #overlay (_string) real:    float64;
        #overlay (_string) array:   tg3json_array;
        #overlay (_string) object:  tg3json_object;
    };
}

tg3json_parse_n :: (data: *u8, len: u64, depth_limit: u64, out_value: *tg3json_value, out_error_pos: **u8) -> s32 #foreign tinygltf;

tg3json_parse :: (begin: *u8, end: *u8, depth_limit: u64, out_value: *tg3json_value, out_error_pos: **u8) -> s32 #foreign tinygltf;

tg3json_parse_options :: struct {
    depth_limit:       u64; /* 0 = default */
    memory_budget:     u64; /* 0 = unlimited */
    max_single_alloc:  u64; /* 0 = unlimited */
    max_string_length: u64; /* 0 = unlimited */
    parse_float32:     s32; /* 1 = round JSON reals to float */
}

tg3json_parse_n_opts :: (data: *u8, len: u64, options: *tg3json_parse_options, out_value: *tg3json_value, out_error_pos: **u8) -> s32 #foreign tinygltf;

tg3json_value_free :: (value: *tg3json_value) -> void #foreign tinygltf;
tg3json_value_init_null :: (value: *tg3json_value) -> void #foreign tinygltf;
tg3json_value_init_bool :: (value: *tg3json_value, boolean_value: s32) -> void #foreign tinygltf;
tg3json_value_init_int :: (value: *tg3json_value, integer_value: s64) -> void #foreign tinygltf;
tg3json_value_init_real :: (value: *tg3json_value, real_value: float64) -> void #foreign tinygltf;
tg3json_value_init_string_n :: (value: *tg3json_value, str: *u8, len: u64) -> s32 #foreign tinygltf;
tg3json_value_init_string :: (value: *tg3json_value, str: *u8) -> s32 #foreign tinygltf;
tg3json_value_init_array :: (value: *tg3json_value) -> void #foreign tinygltf;
tg3json_value_init_object :: (value: *tg3json_value) -> void #foreign tinygltf;
tg3json_value_copy :: (dst: *tg3json_value, src: *tg3json_value) -> s32 #foreign tinygltf;

tg3json_object_get :: (object: *tg3json_value, key: *u8) -> *tg3json_value #foreign tinygltf;

tg3json_object_get_n :: (object: *tg3json_value, key: *u8, key_len: u64) -> *tg3json_value #foreign tinygltf;

tg3json_object_get_mut :: (object: *tg3json_value, key: *u8) -> *tg3json_value #foreign tinygltf;
tg3json_object_get_mut_n :: (object: *tg3json_value, key: *u8, key_len: u64) -> *tg3json_value #foreign tinygltf;

tg3json_object_at :: (object: *tg3json_value, index: u64) -> *tg3json_object_entry #foreign tinygltf;

tg3json_object_size :: (object: *tg3json_value) -> u64 #foreign tinygltf;
tg3json_object_set_take_n :: (object: *tg3json_value, key: *u8, key_len: u64, value: *tg3json_value) -> s32 #foreign tinygltf;

tg3json_object_set_take :: (object: *tg3json_value, key: *u8, value: *tg3json_value) -> s32 #foreign tinygltf;

tg3json_object_set_copy_n :: (object: *tg3json_value, key: *u8, key_len: u64, value: *tg3json_value) -> s32 #foreign tinygltf;

tg3json_object_set_copy :: (object: *tg3json_value, key: *u8, value: *tg3json_value) -> s32 #foreign tinygltf;

tg3json_array_get :: (array: *tg3json_value, index: u64) -> *tg3json_value #foreign tinygltf;
tg3json_array_size :: (array: *tg3json_value) -> u64 #foreign tinygltf;
tg3json_array_append_take :: (array: *tg3json_value, value: *tg3json_value) -> s32 #foreign tinygltf;
tg3json_array_append_copy :: (array: *tg3json_value, value: *tg3json_value) -> s32 #foreign tinygltf;
tg3json_stringify :: (value: *tg3json_value, out_len: *u64) -> *u8 #foreign tinygltf;
tg3json_stringify_pretty :: (value: *tg3json_value, indent: s32, out_len: *u64) -> *u8 #foreign tinygltf;

#scope_file

#import "Basic"; // For assert


#run {
    {
        info := type_info(tg3_str);
        for info.members {
            if it.name == {
                case "data";
                    assert(it.offset_in_bytes == 0, "tg3_str.data has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_str.data has unexpected size % instead of 8", it.type.runtime_size);
                case "len";
                    assert(it.offset_in_bytes == 8, "tg3_str.len has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_str.len has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_str) == 16, "tg3_str has size % instead of 16", size_of(tg3_str));
    }

    {
        info := type_info(tg3_span_i32);
        for info.members {
            if it.name == {
                case "data";
                    assert(it.offset_in_bytes == 0, "tg3_span_i32.data has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_span_i32.data has unexpected size % instead of 8", it.type.runtime_size);
                case "count";
                    assert(it.offset_in_bytes == 8, "tg3_span_i32.count has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_span_i32.count has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_span_i32) == 16, "tg3_span_i32 has size % instead of 16", size_of(tg3_span_i32));
    }

    {
        info := type_info(tg3_span_f64);
        for info.members {
            if it.name == {
                case "data";
                    assert(it.offset_in_bytes == 0, "tg3_span_f64.data has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_span_f64.data has unexpected size % instead of 8", it.type.runtime_size);
                case "count";
                    assert(it.offset_in_bytes == 8, "tg3_span_f64.count has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_span_f64.count has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_span_f64) == 16, "tg3_span_f64 has size % instead of 16", size_of(tg3_span_f64));
    }

    {
        info := type_info(tg3_span_u8);
        for info.members {
            if it.name == {
                case "data";
                    assert(it.offset_in_bytes == 0, "tg3_span_u8.data has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_span_u8.data has unexpected size % instead of 8", it.type.runtime_size);
                case "count";
                    assert(it.offset_in_bytes == 8, "tg3_span_u8.count has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_span_u8.count has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_span_u8) == 16, "tg3_span_u8 has size % instead of 16", size_of(tg3_span_u8));
    }

    {
        info := type_info(tg3_str_int_pair);
        for info.members {
            if it.name == {
                case "key";
                    assert(it.offset_in_bytes == 0, "tg3_str_int_pair.key has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_str_int_pair.key has unexpected size % instead of 16", it.type.runtime_size);
                case "value";
                    assert(it.offset_in_bytes == 16, "tg3_str_int_pair.value has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_str_int_pair.value has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_str_int_pair) == 24, "tg3_str_int_pair has size % instead of 24", size_of(tg3_str_int_pair));
    }

    {
        info := type_info(tg3_allocator);
        for info.members {
            if it.name == {
                case "alloc";
                    assert(it.offset_in_bytes == 0, "tg3_allocator.alloc has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_allocator.alloc has unexpected size % instead of 8", it.type.runtime_size);
                case "realloc";
                    assert(it.offset_in_bytes == 8, "tg3_allocator.realloc has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_allocator.realloc has unexpected size % instead of 8", it.type.runtime_size);
                case "free";
                    assert(it.offset_in_bytes == 16, "tg3_allocator.free has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_allocator.free has unexpected size % instead of 8", it.type.runtime_size);
                case "user_data";
                    assert(it.offset_in_bytes == 24, "tg3_allocator.user_data has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_allocator.user_data has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_allocator) == 32, "tg3_allocator has size % instead of 32", size_of(tg3_allocator));
    }

    {
        info := type_info(tg3_error_entry);
        for info.members {
            if it.name == {
                case "severity";
                    assert(it.offset_in_bytes == 0, "tg3_error_entry.severity has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_error_entry.severity has unexpected size % instead of 4", it.type.runtime_size);
                case "code";
                    assert(it.offset_in_bytes == 4, "tg3_error_entry.code has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_error_entry.code has unexpected size % instead of 4", it.type.runtime_size);
                case "message";
                    assert(it.offset_in_bytes == 8, "tg3_error_entry.message has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_error_entry.message has unexpected size % instead of 8", it.type.runtime_size);
                case "json_path";
                    assert(it.offset_in_bytes == 16, "tg3_error_entry.json_path has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_error_entry.json_path has unexpected size % instead of 8", it.type.runtime_size);
                case "byte_offset";
                    assert(it.offset_in_bytes == 24, "tg3_error_entry.byte_offset has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_error_entry.byte_offset has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_error_entry) == 32, "tg3_error_entry has size % instead of 32", size_of(tg3_error_entry));
    }

    {
        info := type_info(tg3_error_stack);
        for info.members {
            if it.name == {
                case "entries";
                    assert(it.offset_in_bytes == 0, "tg3_error_stack.entries has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_error_stack.entries has unexpected size % instead of 8", it.type.runtime_size);
                case "count";
                    assert(it.offset_in_bytes == 8, "tg3_error_stack.count has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_error_stack.count has unexpected size % instead of 4", it.type.runtime_size);
                case "capacity";
                    assert(it.offset_in_bytes == 12, "tg3_error_stack.capacity has unexpected offset % instead of 12", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_error_stack.capacity has unexpected size % instead of 4", it.type.runtime_size);
                case "has_error";
                    assert(it.offset_in_bytes == 16, "tg3_error_stack.has_error has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_error_stack.has_error has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_error_stack) == 24, "tg3_error_stack has size % instead of 24", size_of(tg3_error_stack));
    }

    {
        info := type_info(tg3_value);
        for info.members {
            if it.name == {
                case "type";
                    assert(it.offset_in_bytes == 0, "tg3_value.type has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_value.type has unexpected size % instead of 4", it.type.runtime_size);
                case "string_val";
                    assert(it.offset_in_bytes == 16, "tg3_value.string_val has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_value.string_val has unexpected size % instead of 16", it.type.runtime_size);
                case "array_data";
                    assert(it.offset_in_bytes == 32, "tg3_value.array_data has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_value.array_data has unexpected size % instead of 8", it.type.runtime_size);
                case "array_count";
                    assert(it.offset_in_bytes == 40, "tg3_value.array_count has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_value.array_count has unexpected size % instead of 4", it.type.runtime_size);
                case "object_data";
                    assert(it.offset_in_bytes == 48, "tg3_value.object_data has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_value.object_data has unexpected size % instead of 8", it.type.runtime_size);
                case "object_count";
                    assert(it.offset_in_bytes == 56, "tg3_value.object_count has unexpected offset % instead of 56", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_value.object_count has unexpected size % instead of 4", it.type.runtime_size);
                case "binary_val";
                    assert(it.offset_in_bytes == 64, "tg3_value.binary_val has unexpected offset % instead of 64", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_value.binary_val has unexpected size % instead of 16", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_value) == 80, "tg3_value has size % instead of 80", size_of(tg3_value));
    }

    {
        info := type_info(tg3_kv_pair);
        for info.members {
            if it.name == {
                case "key";
                    assert(it.offset_in_bytes == 0, "tg3_kv_pair.key has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_kv_pair.key has unexpected size % instead of 16", it.type.runtime_size);
                case "value";
                    assert(it.offset_in_bytes == 16, "tg3_kv_pair.value has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 80, "tg3_kv_pair.value has unexpected size % instead of 80", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_kv_pair) == 96, "tg3_kv_pair has size % instead of 96", size_of(tg3_kv_pair));
    }

    {
        info := type_info(tg3_extension);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_extension.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_extension.name has unexpected size % instead of 16", it.type.runtime_size);
                case "value";
                    assert(it.offset_in_bytes == 16, "tg3_extension.value has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 80, "tg3_extension.value has unexpected size % instead of 80", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_extension) == 96, "tg3_extension has size % instead of 96", size_of(tg3_extension));
    }

    {
        info := type_info(tg3_extras_ext);
        for info.members {
            if it.name == {
                case "extras";
                    assert(it.offset_in_bytes == 0, "tg3_extras_ext.extras has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_extras_ext.extras has unexpected size % instead of 8", it.type.runtime_size);
                case "extensions";
                    assert(it.offset_in_bytes == 8, "tg3_extras_ext.extensions has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_extras_ext.extensions has unexpected size % instead of 8", it.type.runtime_size);
                case "extensions_count";
                    assert(it.offset_in_bytes == 16, "tg3_extras_ext.extensions_count has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_extras_ext.extensions_count has unexpected size % instead of 4", it.type.runtime_size);
                case "extras_json";
                    assert(it.offset_in_bytes == 24, "tg3_extras_ext.extras_json has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_extras_ext.extras_json has unexpected size % instead of 16", it.type.runtime_size);
                case "extensions_json";
                    assert(it.offset_in_bytes == 40, "tg3_extras_ext.extensions_json has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_extras_ext.extensions_json has unexpected size % instead of 16", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_extras_ext) == 56, "tg3_extras_ext has size % instead of 56", size_of(tg3_extras_ext));
    }

    {
        info := type_info(tg3_asset);
        for info.members {
            if it.name == {
                case "version";
                    assert(it.offset_in_bytes == 0, "tg3_asset.version has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_asset.version has unexpected size % instead of 16", it.type.runtime_size);
                case "generator";
                    assert(it.offset_in_bytes == 16, "tg3_asset.generator has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_asset.generator has unexpected size % instead of 16", it.type.runtime_size);
                case "min_version";
                    assert(it.offset_in_bytes == 32, "tg3_asset.min_version has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_asset.min_version has unexpected size % instead of 16", it.type.runtime_size);
                case "copyright";
                    assert(it.offset_in_bytes == 48, "tg3_asset.copyright has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_asset.copyright has unexpected size % instead of 16", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 64, "tg3_asset.ext has unexpected offset % instead of 64", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_asset.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_asset) == 120, "tg3_asset has size % instead of 120", size_of(tg3_asset));
    }

    {
        info := type_info(tg3_buffer);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_buffer.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_buffer.name has unexpected size % instead of 16", it.type.runtime_size);
                case "byte_length";
                    assert(it.offset_in_bytes == 16, "tg3_buffer.byte_length has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_buffer.byte_length has unexpected size % instead of 8", it.type.runtime_size);
                case "data";
                    assert(it.offset_in_bytes == 24, "tg3_buffer.data has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_buffer.data has unexpected size % instead of 16", it.type.runtime_size);
                case "uri";
                    assert(it.offset_in_bytes == 40, "tg3_buffer.uri has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_buffer.uri has unexpected size % instead of 16", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 56, "tg3_buffer.ext has unexpected offset % instead of 56", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_buffer.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_buffer) == 112, "tg3_buffer has size % instead of 112", size_of(tg3_buffer));
    }

    {
        info := type_info(tg3_buffer_view);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_buffer_view.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_buffer_view.name has unexpected size % instead of 16", it.type.runtime_size);
                case "buffer";
                    assert(it.offset_in_bytes == 16, "tg3_buffer_view.buffer has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_buffer_view.buffer has unexpected size % instead of 4", it.type.runtime_size);
                case "byte_offset";
                    assert(it.offset_in_bytes == 24, "tg3_buffer_view.byte_offset has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_buffer_view.byte_offset has unexpected size % instead of 8", it.type.runtime_size);
                case "byte_length";
                    assert(it.offset_in_bytes == 32, "tg3_buffer_view.byte_length has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_buffer_view.byte_length has unexpected size % instead of 8", it.type.runtime_size);
                case "byte_stride";
                    assert(it.offset_in_bytes == 40, "tg3_buffer_view.byte_stride has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_buffer_view.byte_stride has unexpected size % instead of 4", it.type.runtime_size);
                case "target";
                    assert(it.offset_in_bytes == 44, "tg3_buffer_view.target has unexpected offset % instead of 44", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_buffer_view.target has unexpected size % instead of 4", it.type.runtime_size);
                case "draco_decoded";
                    assert(it.offset_in_bytes == 48, "tg3_buffer_view.draco_decoded has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_buffer_view.draco_decoded has unexpected size % instead of 4", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 56, "tg3_buffer_view.ext has unexpected offset % instead of 56", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_buffer_view.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_buffer_view) == 112, "tg3_buffer_view has size % instead of 112", size_of(tg3_buffer_view));
    }

    {
        info := type_info(tg3_accessor_sparse_indices);
        for info.members {
            if it.name == {
                case "byte_offset";
                    assert(it.offset_in_bytes == 0, "tg3_accessor_sparse_indices.byte_offset has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_accessor_sparse_indices.byte_offset has unexpected size % instead of 8", it.type.runtime_size);
                case "buffer_view";
                    assert(it.offset_in_bytes == 8, "tg3_accessor_sparse_indices.buffer_view has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_accessor_sparse_indices.buffer_view has unexpected size % instead of 4", it.type.runtime_size);
                case "component_type";
                    assert(it.offset_in_bytes == 12, "tg3_accessor_sparse_indices.component_type has unexpected offset % instead of 12", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_accessor_sparse_indices.component_type has unexpected size % instead of 4", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 16, "tg3_accessor_sparse_indices.ext has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_accessor_sparse_indices.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_accessor_sparse_indices) == 72, "tg3_accessor_sparse_indices has size % instead of 72", size_of(tg3_accessor_sparse_indices));
    }

    {
        info := type_info(tg3_accessor_sparse_values);
        for info.members {
            if it.name == {
                case "buffer_view";
                    assert(it.offset_in_bytes == 0, "tg3_accessor_sparse_values.buffer_view has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_accessor_sparse_values.buffer_view has unexpected size % instead of 4", it.type.runtime_size);
                case "byte_offset";
                    assert(it.offset_in_bytes == 8, "tg3_accessor_sparse_values.byte_offset has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_accessor_sparse_values.byte_offset has unexpected size % instead of 8", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 16, "tg3_accessor_sparse_values.ext has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_accessor_sparse_values.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_accessor_sparse_values) == 72, "tg3_accessor_sparse_values has size % instead of 72", size_of(tg3_accessor_sparse_values));
    }

    {
        info := type_info(tg3_accessor_sparse);
        for info.members {
            if it.name == {
                case "count";
                    assert(it.offset_in_bytes == 0, "tg3_accessor_sparse.count has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_accessor_sparse.count has unexpected size % instead of 4", it.type.runtime_size);
                case "is_sparse";
                    assert(it.offset_in_bytes == 4, "tg3_accessor_sparse.is_sparse has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_accessor_sparse.is_sparse has unexpected size % instead of 4", it.type.runtime_size);
                case "indices";
                    assert(it.offset_in_bytes == 8, "tg3_accessor_sparse.indices has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 72, "tg3_accessor_sparse.indices has unexpected size % instead of 72", it.type.runtime_size);
                case "values";
                    assert(it.offset_in_bytes == 80, "tg3_accessor_sparse.values has unexpected offset % instead of 80", it.offset_in_bytes);
                    assert(it.type.runtime_size == 72, "tg3_accessor_sparse.values has unexpected size % instead of 72", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 152, "tg3_accessor_sparse.ext has unexpected offset % instead of 152", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_accessor_sparse.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_accessor_sparse) == 208, "tg3_accessor_sparse has size % instead of 208", size_of(tg3_accessor_sparse));
    }

    {
        info := type_info(tg3_accessor);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_accessor.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_accessor.name has unexpected size % instead of 16", it.type.runtime_size);
                case "buffer_view";
                    assert(it.offset_in_bytes == 16, "tg3_accessor.buffer_view has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_accessor.buffer_view has unexpected size % instead of 4", it.type.runtime_size);
                case "byte_offset";
                    assert(it.offset_in_bytes == 24, "tg3_accessor.byte_offset has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_accessor.byte_offset has unexpected size % instead of 8", it.type.runtime_size);
                case "normalized";
                    assert(it.offset_in_bytes == 32, "tg3_accessor.normalized has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_accessor.normalized has unexpected size % instead of 4", it.type.runtime_size);
                case "component_type";
                    assert(it.offset_in_bytes == 36, "tg3_accessor.component_type has unexpected offset % instead of 36", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_accessor.component_type has unexpected size % instead of 4", it.type.runtime_size);
                case "count";
                    assert(it.offset_in_bytes == 40, "tg3_accessor.count has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_accessor.count has unexpected size % instead of 8", it.type.runtime_size);
                case "type";
                    assert(it.offset_in_bytes == 48, "tg3_accessor.type has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_accessor.type has unexpected size % instead of 4", it.type.runtime_size);
                case "min_values";
                    assert(it.offset_in_bytes == 56, "tg3_accessor.min_values has unexpected offset % instead of 56", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_accessor.min_values has unexpected size % instead of 8", it.type.runtime_size);
                case "min_values_count";
                    assert(it.offset_in_bytes == 64, "tg3_accessor.min_values_count has unexpected offset % instead of 64", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_accessor.min_values_count has unexpected size % instead of 4", it.type.runtime_size);
                case "max_values";
                    assert(it.offset_in_bytes == 72, "tg3_accessor.max_values has unexpected offset % instead of 72", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_accessor.max_values has unexpected size % instead of 8", it.type.runtime_size);
                case "max_values_count";
                    assert(it.offset_in_bytes == 80, "tg3_accessor.max_values_count has unexpected offset % instead of 80", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_accessor.max_values_count has unexpected size % instead of 4", it.type.runtime_size);
                case "sparse";
                    assert(it.offset_in_bytes == 88, "tg3_accessor.sparse has unexpected offset % instead of 88", it.offset_in_bytes);
                    assert(it.type.runtime_size == 208, "tg3_accessor.sparse has unexpected size % instead of 208", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 296, "tg3_accessor.ext has unexpected offset % instead of 296", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_accessor.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_accessor) == 352, "tg3_accessor has size % instead of 352", size_of(tg3_accessor));
    }

    {
        info := type_info(tg3_image);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_image.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_image.name has unexpected size % instead of 16", it.type.runtime_size);
                case "width";
                    assert(it.offset_in_bytes == 16, "tg3_image.width has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image.width has unexpected size % instead of 4", it.type.runtime_size);
                case "height";
                    assert(it.offset_in_bytes == 20, "tg3_image.height has unexpected offset % instead of 20", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image.height has unexpected size % instead of 4", it.type.runtime_size);
                case "component";
                    assert(it.offset_in_bytes == 24, "tg3_image.component has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image.component has unexpected size % instead of 4", it.type.runtime_size);
                case "bits";
                    assert(it.offset_in_bytes == 28, "tg3_image.bits has unexpected offset % instead of 28", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image.bits has unexpected size % instead of 4", it.type.runtime_size);
                case "pixel_type";
                    assert(it.offset_in_bytes == 32, "tg3_image.pixel_type has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image.pixel_type has unexpected size % instead of 4", it.type.runtime_size);
                case "image";
                    assert(it.offset_in_bytes == 40, "tg3_image.image has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_image.image has unexpected size % instead of 16", it.type.runtime_size);
                case "buffer_view";
                    assert(it.offset_in_bytes == 56, "tg3_image.buffer_view has unexpected offset % instead of 56", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image.buffer_view has unexpected size % instead of 4", it.type.runtime_size);
                case "mime_type";
                    assert(it.offset_in_bytes == 64, "tg3_image.mime_type has unexpected offset % instead of 64", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_image.mime_type has unexpected size % instead of 16", it.type.runtime_size);
                case "uri";
                    assert(it.offset_in_bytes == 80, "tg3_image.uri has unexpected offset % instead of 80", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_image.uri has unexpected size % instead of 16", it.type.runtime_size);
                case "as_is";
                    assert(it.offset_in_bytes == 96, "tg3_image.as_is has unexpected offset % instead of 96", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image.as_is has unexpected size % instead of 4", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 104, "tg3_image.ext has unexpected offset % instead of 104", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_image.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_image) == 160, "tg3_image has size % instead of 160", size_of(tg3_image));
    }

    {
        info := type_info(tg3_sampler);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_sampler.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_sampler.name has unexpected size % instead of 16", it.type.runtime_size);
                case "min_filter";
                    assert(it.offset_in_bytes == 16, "tg3_sampler.min_filter has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_sampler.min_filter has unexpected size % instead of 4", it.type.runtime_size);
                case "mag_filter";
                    assert(it.offset_in_bytes == 20, "tg3_sampler.mag_filter has unexpected offset % instead of 20", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_sampler.mag_filter has unexpected size % instead of 4", it.type.runtime_size);
                case "wrap_s";
                    assert(it.offset_in_bytes == 24, "tg3_sampler.wrap_s has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_sampler.wrap_s has unexpected size % instead of 4", it.type.runtime_size);
                case "wrap_t";
                    assert(it.offset_in_bytes == 28, "tg3_sampler.wrap_t has unexpected offset % instead of 28", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_sampler.wrap_t has unexpected size % instead of 4", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 32, "tg3_sampler.ext has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_sampler.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_sampler) == 88, "tg3_sampler has size % instead of 88", size_of(tg3_sampler));
    }

    {
        info := type_info(tg3_texture);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_texture.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_texture.name has unexpected size % instead of 16", it.type.runtime_size);
                case "sampler";
                    assert(it.offset_in_bytes == 16, "tg3_texture.sampler has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_texture.sampler has unexpected size % instead of 4", it.type.runtime_size);
                case "source";
                    assert(it.offset_in_bytes == 20, "tg3_texture.source has unexpected offset % instead of 20", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_texture.source has unexpected size % instead of 4", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 24, "tg3_texture.ext has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_texture.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_texture) == 80, "tg3_texture has size % instead of 80", size_of(tg3_texture));
    }

    {
        info := type_info(tg3_texture_info);
        for info.members {
            if it.name == {
                case "index";
                    assert(it.offset_in_bytes == 0, "tg3_texture_info.index has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_texture_info.index has unexpected size % instead of 4", it.type.runtime_size);
                case "tex_coord";
                    assert(it.offset_in_bytes == 4, "tg3_texture_info.tex_coord has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_texture_info.tex_coord has unexpected size % instead of 4", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 8, "tg3_texture_info.ext has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_texture_info.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_texture_info) == 64, "tg3_texture_info has size % instead of 64", size_of(tg3_texture_info));
    }

    {
        info := type_info(tg3_normal_texture_info);
        for info.members {
            if it.name == {
                case "index";
                    assert(it.offset_in_bytes == 0, "tg3_normal_texture_info.index has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_normal_texture_info.index has unexpected size % instead of 4", it.type.runtime_size);
                case "tex_coord";
                    assert(it.offset_in_bytes == 4, "tg3_normal_texture_info.tex_coord has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_normal_texture_info.tex_coord has unexpected size % instead of 4", it.type.runtime_size);
                case "scale";
                    assert(it.offset_in_bytes == 8, "tg3_normal_texture_info.scale has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_normal_texture_info.scale has unexpected size % instead of 8", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 16, "tg3_normal_texture_info.ext has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_normal_texture_info.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_normal_texture_info) == 72, "tg3_normal_texture_info has size % instead of 72", size_of(tg3_normal_texture_info));
    }

    {
        info := type_info(tg3_occlusion_texture_info);
        for info.members {
            if it.name == {
                case "index";
                    assert(it.offset_in_bytes == 0, "tg3_occlusion_texture_info.index has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_occlusion_texture_info.index has unexpected size % instead of 4", it.type.runtime_size);
                case "tex_coord";
                    assert(it.offset_in_bytes == 4, "tg3_occlusion_texture_info.tex_coord has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_occlusion_texture_info.tex_coord has unexpected size % instead of 4", it.type.runtime_size);
                case "strength";
                    assert(it.offset_in_bytes == 8, "tg3_occlusion_texture_info.strength has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_occlusion_texture_info.strength has unexpected size % instead of 8", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 16, "tg3_occlusion_texture_info.ext has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_occlusion_texture_info.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_occlusion_texture_info) == 72, "tg3_occlusion_texture_info has size % instead of 72", size_of(tg3_occlusion_texture_info));
    }

    {
        info := type_info(tg3_pbr_metallic_roughness);
        for info.members {
            if it.name == {
                case "base_color_factor";
                    assert(it.offset_in_bytes == 0, "tg3_pbr_metallic_roughness.base_color_factor has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 32, "tg3_pbr_metallic_roughness.base_color_factor has unexpected size % instead of 32", it.type.runtime_size);
                case "base_color_texture";
                    assert(it.offset_in_bytes == 32, "tg3_pbr_metallic_roughness.base_color_texture has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 64, "tg3_pbr_metallic_roughness.base_color_texture has unexpected size % instead of 64", it.type.runtime_size);
                case "metallic_factor";
                    assert(it.offset_in_bytes == 96, "tg3_pbr_metallic_roughness.metallic_factor has unexpected offset % instead of 96", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_pbr_metallic_roughness.metallic_factor has unexpected size % instead of 8", it.type.runtime_size);
                case "roughness_factor";
                    assert(it.offset_in_bytes == 104, "tg3_pbr_metallic_roughness.roughness_factor has unexpected offset % instead of 104", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_pbr_metallic_roughness.roughness_factor has unexpected size % instead of 8", it.type.runtime_size);
                case "metallic_roughness_texture";
                    assert(it.offset_in_bytes == 112, "tg3_pbr_metallic_roughness.metallic_roughness_texture has unexpected offset % instead of 112", it.offset_in_bytes);
                    assert(it.type.runtime_size == 64, "tg3_pbr_metallic_roughness.metallic_roughness_texture has unexpected size % instead of 64", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 176, "tg3_pbr_metallic_roughness.ext has unexpected offset % instead of 176", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_pbr_metallic_roughness.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_pbr_metallic_roughness) == 232, "tg3_pbr_metallic_roughness has size % instead of 232", size_of(tg3_pbr_metallic_roughness));
    }

    {
        info := type_info(tg3_material);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_material.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_material.name has unexpected size % instead of 16", it.type.runtime_size);
                case "emissive_factor";
                    assert(it.offset_in_bytes == 16, "tg3_material.emissive_factor has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 24, "tg3_material.emissive_factor has unexpected size % instead of 24", it.type.runtime_size);
                case "alpha_mode";
                    assert(it.offset_in_bytes == 40, "tg3_material.alpha_mode has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_material.alpha_mode has unexpected size % instead of 16", it.type.runtime_size);
                case "alpha_cutoff";
                    assert(it.offset_in_bytes == 56, "tg3_material.alpha_cutoff has unexpected offset % instead of 56", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_material.alpha_cutoff has unexpected size % instead of 8", it.type.runtime_size);
                case "double_sided";
                    assert(it.offset_in_bytes == 64, "tg3_material.double_sided has unexpected offset % instead of 64", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_material.double_sided has unexpected size % instead of 4", it.type.runtime_size);
                case "lods";
                    assert(it.offset_in_bytes == 72, "tg3_material.lods has unexpected offset % instead of 72", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_material.lods has unexpected size % instead of 8", it.type.runtime_size);
                case "lods_count";
                    assert(it.offset_in_bytes == 80, "tg3_material.lods_count has unexpected offset % instead of 80", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_material.lods_count has unexpected size % instead of 4", it.type.runtime_size);
                case "pbr_metallic_roughness";
                    assert(it.offset_in_bytes == 88, "tg3_material.pbr_metallic_roughness has unexpected offset % instead of 88", it.offset_in_bytes);
                    assert(it.type.runtime_size == 232, "tg3_material.pbr_metallic_roughness has unexpected size % instead of 232", it.type.runtime_size);
                case "normal_texture";
                    assert(it.offset_in_bytes == 320, "tg3_material.normal_texture has unexpected offset % instead of 320", it.offset_in_bytes);
                    assert(it.type.runtime_size == 72, "tg3_material.normal_texture has unexpected size % instead of 72", it.type.runtime_size);
                case "occlusion_texture";
                    assert(it.offset_in_bytes == 392, "tg3_material.occlusion_texture has unexpected offset % instead of 392", it.offset_in_bytes);
                    assert(it.type.runtime_size == 72, "tg3_material.occlusion_texture has unexpected size % instead of 72", it.type.runtime_size);
                case "emissive_texture";
                    assert(it.offset_in_bytes == 464, "tg3_material.emissive_texture has unexpected offset % instead of 464", it.offset_in_bytes);
                    assert(it.type.runtime_size == 64, "tg3_material.emissive_texture has unexpected size % instead of 64", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 528, "tg3_material.ext has unexpected offset % instead of 528", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_material.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_material) == 584, "tg3_material has size % instead of 584", size_of(tg3_material));
    }

    {
        info := type_info(tg3_primitive);
        for info.members {
            if it.name == {
                case "attributes";
                    assert(it.offset_in_bytes == 0, "tg3_primitive.attributes has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_primitive.attributes has unexpected size % instead of 8", it.type.runtime_size);
                case "attributes_count";
                    assert(it.offset_in_bytes == 8, "tg3_primitive.attributes_count has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_primitive.attributes_count has unexpected size % instead of 4", it.type.runtime_size);
                case "material";
                    assert(it.offset_in_bytes == 12, "tg3_primitive.material has unexpected offset % instead of 12", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_primitive.material has unexpected size % instead of 4", it.type.runtime_size);
                case "indices";
                    assert(it.offset_in_bytes == 16, "tg3_primitive.indices has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_primitive.indices has unexpected size % instead of 4", it.type.runtime_size);
                case "mode";
                    assert(it.offset_in_bytes == 20, "tg3_primitive.mode has unexpected offset % instead of 20", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_primitive.mode has unexpected size % instead of 4", it.type.runtime_size);
                case "targets";
                    assert(it.offset_in_bytes == 24, "tg3_primitive.targets has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_primitive.targets has unexpected size % instead of 8", it.type.runtime_size);
                case "target_attribute_counts";
                    assert(it.offset_in_bytes == 32, "tg3_primitive.target_attribute_counts has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_primitive.target_attribute_counts has unexpected size % instead of 8", it.type.runtime_size);
                case "targets_count";
                    assert(it.offset_in_bytes == 40, "tg3_primitive.targets_count has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_primitive.targets_count has unexpected size % instead of 4", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 48, "tg3_primitive.ext has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_primitive.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_primitive) == 104, "tg3_primitive has size % instead of 104", size_of(tg3_primitive));
    }

    {
        info := type_info(tg3_mesh);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_mesh.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_mesh.name has unexpected size % instead of 16", it.type.runtime_size);
                case "primitives";
                    assert(it.offset_in_bytes == 16, "tg3_mesh.primitives has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_mesh.primitives has unexpected size % instead of 8", it.type.runtime_size);
                case "primitives_count";
                    assert(it.offset_in_bytes == 24, "tg3_mesh.primitives_count has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_mesh.primitives_count has unexpected size % instead of 4", it.type.runtime_size);
                case "weights";
                    assert(it.offset_in_bytes == 32, "tg3_mesh.weights has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_mesh.weights has unexpected size % instead of 8", it.type.runtime_size);
                case "weights_count";
                    assert(it.offset_in_bytes == 40, "tg3_mesh.weights_count has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_mesh.weights_count has unexpected size % instead of 4", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 48, "tg3_mesh.ext has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_mesh.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_mesh) == 104, "tg3_mesh has size % instead of 104", size_of(tg3_mesh));
    }

    {
        info := type_info(tg3_node);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_node.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_node.name has unexpected size % instead of 16", it.type.runtime_size);
                case "camera";
                    assert(it.offset_in_bytes == 16, "tg3_node.camera has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_node.camera has unexpected size % instead of 4", it.type.runtime_size);
                case "skin";
                    assert(it.offset_in_bytes == 20, "tg3_node.skin has unexpected offset % instead of 20", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_node.skin has unexpected size % instead of 4", it.type.runtime_size);
                case "mesh";
                    assert(it.offset_in_bytes == 24, "tg3_node.mesh has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_node.mesh has unexpected size % instead of 4", it.type.runtime_size);
                case "light";
                    assert(it.offset_in_bytes == 28, "tg3_node.light has unexpected offset % instead of 28", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_node.light has unexpected size % instead of 4", it.type.runtime_size);
                case "emitter";
                    assert(it.offset_in_bytes == 32, "tg3_node.emitter has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_node.emitter has unexpected size % instead of 4", it.type.runtime_size);
                case "lods";
                    assert(it.offset_in_bytes == 40, "tg3_node.lods has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_node.lods has unexpected size % instead of 8", it.type.runtime_size);
                case "lods_count";
                    assert(it.offset_in_bytes == 48, "tg3_node.lods_count has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_node.lods_count has unexpected size % instead of 4", it.type.runtime_size);
                case "children";
                    assert(it.offset_in_bytes == 56, "tg3_node.children has unexpected offset % instead of 56", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_node.children has unexpected size % instead of 8", it.type.runtime_size);
                case "children_count";
                    assert(it.offset_in_bytes == 64, "tg3_node.children_count has unexpected offset % instead of 64", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_node.children_count has unexpected size % instead of 4", it.type.runtime_size);
                case "rotation";
                    assert(it.offset_in_bytes == 72, "tg3_node.rotation has unexpected offset % instead of 72", it.offset_in_bytes);
                    assert(it.type.runtime_size == 32, "tg3_node.rotation has unexpected size % instead of 32", it.type.runtime_size);
                case "scale";
                    assert(it.offset_in_bytes == 104, "tg3_node.scale has unexpected offset % instead of 104", it.offset_in_bytes);
                    assert(it.type.runtime_size == 24, "tg3_node.scale has unexpected size % instead of 24", it.type.runtime_size);
                case "translation";
                    assert(it.offset_in_bytes == 128, "tg3_node.translation has unexpected offset % instead of 128", it.offset_in_bytes);
                    assert(it.type.runtime_size == 24, "tg3_node.translation has unexpected size % instead of 24", it.type.runtime_size);
                case "matrix";
                    assert(it.offset_in_bytes == 152, "tg3_node.matrix has unexpected offset % instead of 152", it.offset_in_bytes);
                    assert(it.type.runtime_size == 128, "tg3_node.matrix has unexpected size % instead of 128", it.type.runtime_size);
                case "has_matrix";
                    assert(it.offset_in_bytes == 280, "tg3_node.has_matrix has unexpected offset % instead of 280", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_node.has_matrix has unexpected size % instead of 4", it.type.runtime_size);
                case "weights";
                    assert(it.offset_in_bytes == 288, "tg3_node.weights has unexpected offset % instead of 288", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_node.weights has unexpected size % instead of 8", it.type.runtime_size);
                case "weights_count";
                    assert(it.offset_in_bytes == 296, "tg3_node.weights_count has unexpected offset % instead of 296", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_node.weights_count has unexpected size % instead of 4", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 304, "tg3_node.ext has unexpected offset % instead of 304", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_node.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_node) == 360, "tg3_node has size % instead of 360", size_of(tg3_node));
    }

    {
        info := type_info(tg3_skin);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_skin.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_skin.name has unexpected size % instead of 16", it.type.runtime_size);
                case "inverse_bind_matrices";
                    assert(it.offset_in_bytes == 16, "tg3_skin.inverse_bind_matrices has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_skin.inverse_bind_matrices has unexpected size % instead of 4", it.type.runtime_size);
                case "skeleton";
                    assert(it.offset_in_bytes == 20, "tg3_skin.skeleton has unexpected offset % instead of 20", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_skin.skeleton has unexpected size % instead of 4", it.type.runtime_size);
                case "joints";
                    assert(it.offset_in_bytes == 24, "tg3_skin.joints has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_skin.joints has unexpected size % instead of 8", it.type.runtime_size);
                case "joints_count";
                    assert(it.offset_in_bytes == 32, "tg3_skin.joints_count has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_skin.joints_count has unexpected size % instead of 4", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 40, "tg3_skin.ext has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_skin.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_skin) == 96, "tg3_skin has size % instead of 96", size_of(tg3_skin));
    }

    {
        info := type_info(tg3_animation_channel_target);
        for info.members {
            if it.name == {
                case "node";
                    assert(it.offset_in_bytes == 0, "tg3_animation_channel_target.node has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_animation_channel_target.node has unexpected size % instead of 4", it.type.runtime_size);
                case "path";
                    assert(it.offset_in_bytes == 8, "tg3_animation_channel_target.path has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_animation_channel_target.path has unexpected size % instead of 16", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 24, "tg3_animation_channel_target.ext has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_animation_channel_target.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_animation_channel_target) == 80, "tg3_animation_channel_target has size % instead of 80", size_of(tg3_animation_channel_target));
    }

    {
        info := type_info(tg3_animation_channel);
        for info.members {
            if it.name == {
                case "sampler";
                    assert(it.offset_in_bytes == 0, "tg3_animation_channel.sampler has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_animation_channel.sampler has unexpected size % instead of 4", it.type.runtime_size);
                case "target";
                    assert(it.offset_in_bytes == 8, "tg3_animation_channel.target has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 80, "tg3_animation_channel.target has unexpected size % instead of 80", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 88, "tg3_animation_channel.ext has unexpected offset % instead of 88", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_animation_channel.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_animation_channel) == 144, "tg3_animation_channel has size % instead of 144", size_of(tg3_animation_channel));
    }

    {
        info := type_info(tg3_animation_sampler);
        for info.members {
            if it.name == {
                case "input";
                    assert(it.offset_in_bytes == 0, "tg3_animation_sampler.input has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_animation_sampler.input has unexpected size % instead of 4", it.type.runtime_size);
                case "output";
                    assert(it.offset_in_bytes == 4, "tg3_animation_sampler.output has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_animation_sampler.output has unexpected size % instead of 4", it.type.runtime_size);
                case "interpolation";
                    assert(it.offset_in_bytes == 8, "tg3_animation_sampler.interpolation has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_animation_sampler.interpolation has unexpected size % instead of 16", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 24, "tg3_animation_sampler.ext has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_animation_sampler.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_animation_sampler) == 80, "tg3_animation_sampler has size % instead of 80", size_of(tg3_animation_sampler));
    }

    {
        info := type_info(tg3_animation);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_animation.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_animation.name has unexpected size % instead of 16", it.type.runtime_size);
                case "channels";
                    assert(it.offset_in_bytes == 16, "tg3_animation.channels has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_animation.channels has unexpected size % instead of 8", it.type.runtime_size);
                case "channels_count";
                    assert(it.offset_in_bytes == 24, "tg3_animation.channels_count has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_animation.channels_count has unexpected size % instead of 4", it.type.runtime_size);
                case "samplers";
                    assert(it.offset_in_bytes == 32, "tg3_animation.samplers has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_animation.samplers has unexpected size % instead of 8", it.type.runtime_size);
                case "samplers_count";
                    assert(it.offset_in_bytes == 40, "tg3_animation.samplers_count has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_animation.samplers_count has unexpected size % instead of 4", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 48, "tg3_animation.ext has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_animation.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_animation) == 104, "tg3_animation has size % instead of 104", size_of(tg3_animation));
    }

    {
        info := type_info(tg3_perspective_camera);
        for info.members {
            if it.name == {
                case "aspect_ratio";
                    assert(it.offset_in_bytes == 0, "tg3_perspective_camera.aspect_ratio has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_perspective_camera.aspect_ratio has unexpected size % instead of 8", it.type.runtime_size);
                case "yfov";
                    assert(it.offset_in_bytes == 8, "tg3_perspective_camera.yfov has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_perspective_camera.yfov has unexpected size % instead of 8", it.type.runtime_size);
                case "zfar";
                    assert(it.offset_in_bytes == 16, "tg3_perspective_camera.zfar has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_perspective_camera.zfar has unexpected size % instead of 8", it.type.runtime_size);
                case "znear";
                    assert(it.offset_in_bytes == 24, "tg3_perspective_camera.znear has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_perspective_camera.znear has unexpected size % instead of 8", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 32, "tg3_perspective_camera.ext has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_perspective_camera.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_perspective_camera) == 88, "tg3_perspective_camera has size % instead of 88", size_of(tg3_perspective_camera));
    }

    {
        info := type_info(tg3_orthographic_camera);
        for info.members {
            if it.name == {
                case "xmag";
                    assert(it.offset_in_bytes == 0, "tg3_orthographic_camera.xmag has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_orthographic_camera.xmag has unexpected size % instead of 8", it.type.runtime_size);
                case "ymag";
                    assert(it.offset_in_bytes == 8, "tg3_orthographic_camera.ymag has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_orthographic_camera.ymag has unexpected size % instead of 8", it.type.runtime_size);
                case "zfar";
                    assert(it.offset_in_bytes == 16, "tg3_orthographic_camera.zfar has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_orthographic_camera.zfar has unexpected size % instead of 8", it.type.runtime_size);
                case "znear";
                    assert(it.offset_in_bytes == 24, "tg3_orthographic_camera.znear has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_orthographic_camera.znear has unexpected size % instead of 8", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 32, "tg3_orthographic_camera.ext has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_orthographic_camera.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_orthographic_camera) == 88, "tg3_orthographic_camera has size % instead of 88", size_of(tg3_orthographic_camera));
    }

    {
        info := type_info(tg3_camera);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_camera.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_camera.name has unexpected size % instead of 16", it.type.runtime_size);
                case "type";
                    assert(it.offset_in_bytes == 16, "tg3_camera.type has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_camera.type has unexpected size % instead of 16", it.type.runtime_size);
                case "perspective";
                    assert(it.offset_in_bytes == 32, "tg3_camera.perspective has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 88, "tg3_camera.perspective has unexpected size % instead of 88", it.type.runtime_size);
                case "orthographic";
                    assert(it.offset_in_bytes == 120, "tg3_camera.orthographic has unexpected offset % instead of 120", it.offset_in_bytes);
                    assert(it.type.runtime_size == 88, "tg3_camera.orthographic has unexpected size % instead of 88", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 208, "tg3_camera.ext has unexpected offset % instead of 208", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_camera.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_camera) == 264, "tg3_camera has size % instead of 264", size_of(tg3_camera));
    }

    {
        info := type_info(tg3_scene);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_scene.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_scene.name has unexpected size % instead of 16", it.type.runtime_size);
                case "nodes";
                    assert(it.offset_in_bytes == 16, "tg3_scene.nodes has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_scene.nodes has unexpected size % instead of 8", it.type.runtime_size);
                case "nodes_count";
                    assert(it.offset_in_bytes == 24, "tg3_scene.nodes_count has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_scene.nodes_count has unexpected size % instead of 4", it.type.runtime_size);
                case "audio_emitters";
                    assert(it.offset_in_bytes == 32, "tg3_scene.audio_emitters has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_scene.audio_emitters has unexpected size % instead of 8", it.type.runtime_size);
                case "audio_emitters_count";
                    assert(it.offset_in_bytes == 40, "tg3_scene.audio_emitters_count has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_scene.audio_emitters_count has unexpected size % instead of 4", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 48, "tg3_scene.ext has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_scene.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_scene) == 104, "tg3_scene has size % instead of 104", size_of(tg3_scene));
    }

    {
        info := type_info(tg3_spot_light);
        for info.members {
            if it.name == {
                case "inner_cone_angle";
                    assert(it.offset_in_bytes == 0, "tg3_spot_light.inner_cone_angle has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_spot_light.inner_cone_angle has unexpected size % instead of 8", it.type.runtime_size);
                case "outer_cone_angle";
                    assert(it.offset_in_bytes == 8, "tg3_spot_light.outer_cone_angle has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_spot_light.outer_cone_angle has unexpected size % instead of 8", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 16, "tg3_spot_light.ext has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_spot_light.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_spot_light) == 72, "tg3_spot_light has size % instead of 72", size_of(tg3_spot_light));
    }

    {
        info := type_info(tg3_light);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_light.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_light.name has unexpected size % instead of 16", it.type.runtime_size);
                case "color";
                    assert(it.offset_in_bytes == 16, "tg3_light.color has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 24, "tg3_light.color has unexpected size % instead of 24", it.type.runtime_size);
                case "intensity";
                    assert(it.offset_in_bytes == 40, "tg3_light.intensity has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_light.intensity has unexpected size % instead of 8", it.type.runtime_size);
                case "type";
                    assert(it.offset_in_bytes == 48, "tg3_light.type has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_light.type has unexpected size % instead of 16", it.type.runtime_size);
                case "range";
                    assert(it.offset_in_bytes == 64, "tg3_light.range has unexpected offset % instead of 64", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_light.range has unexpected size % instead of 8", it.type.runtime_size);
                case "spot";
                    assert(it.offset_in_bytes == 72, "tg3_light.spot has unexpected offset % instead of 72", it.offset_in_bytes);
                    assert(it.type.runtime_size == 72, "tg3_light.spot has unexpected size % instead of 72", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 144, "tg3_light.ext has unexpected offset % instead of 144", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_light.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_light) == 200, "tg3_light has size % instead of 200", size_of(tg3_light));
    }

    {
        info := type_info(tg3_audio_source);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_audio_source.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_audio_source.name has unexpected size % instead of 16", it.type.runtime_size);
                case "uri";
                    assert(it.offset_in_bytes == 16, "tg3_audio_source.uri has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_audio_source.uri has unexpected size % instead of 16", it.type.runtime_size);
                case "buffer_view";
                    assert(it.offset_in_bytes == 32, "tg3_audio_source.buffer_view has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_audio_source.buffer_view has unexpected size % instead of 4", it.type.runtime_size);
                case "mime_type";
                    assert(it.offset_in_bytes == 40, "tg3_audio_source.mime_type has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_audio_source.mime_type has unexpected size % instead of 16", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 56, "tg3_audio_source.ext has unexpected offset % instead of 56", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_audio_source.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_audio_source) == 112, "tg3_audio_source has size % instead of 112", size_of(tg3_audio_source));
    }

    {
        info := type_info(tg3_positional_emitter);
        for info.members {
            if it.name == {
                case "cone_inner_angle";
                    assert(it.offset_in_bytes == 0, "tg3_positional_emitter.cone_inner_angle has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_positional_emitter.cone_inner_angle has unexpected size % instead of 8", it.type.runtime_size);
                case "cone_outer_angle";
                    assert(it.offset_in_bytes == 8, "tg3_positional_emitter.cone_outer_angle has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_positional_emitter.cone_outer_angle has unexpected size % instead of 8", it.type.runtime_size);
                case "cone_outer_gain";
                    assert(it.offset_in_bytes == 16, "tg3_positional_emitter.cone_outer_gain has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_positional_emitter.cone_outer_gain has unexpected size % instead of 8", it.type.runtime_size);
                case "max_distance";
                    assert(it.offset_in_bytes == 24, "tg3_positional_emitter.max_distance has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_positional_emitter.max_distance has unexpected size % instead of 8", it.type.runtime_size);
                case "ref_distance";
                    assert(it.offset_in_bytes == 32, "tg3_positional_emitter.ref_distance has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_positional_emitter.ref_distance has unexpected size % instead of 8", it.type.runtime_size);
                case "rolloff_factor";
                    assert(it.offset_in_bytes == 40, "tg3_positional_emitter.rolloff_factor has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_positional_emitter.rolloff_factor has unexpected size % instead of 8", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 48, "tg3_positional_emitter.ext has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_positional_emitter.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_positional_emitter) == 104, "tg3_positional_emitter has size % instead of 104", size_of(tg3_positional_emitter));
    }

    {
        info := type_info(tg3_audio_emitter);
        for info.members {
            if it.name == {
                case "name";
                    assert(it.offset_in_bytes == 0, "tg3_audio_emitter.name has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_audio_emitter.name has unexpected size % instead of 16", it.type.runtime_size);
                case "gain";
                    assert(it.offset_in_bytes == 16, "tg3_audio_emitter.gain has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_audio_emitter.gain has unexpected size % instead of 8", it.type.runtime_size);
                case "loop";
                    assert(it.offset_in_bytes == 24, "tg3_audio_emitter.loop has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_audio_emitter.loop has unexpected size % instead of 4", it.type.runtime_size);
                case "playing";
                    assert(it.offset_in_bytes == 28, "tg3_audio_emitter.playing has unexpected offset % instead of 28", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_audio_emitter.playing has unexpected size % instead of 4", it.type.runtime_size);
                case "type";
                    assert(it.offset_in_bytes == 32, "tg3_audio_emitter.type has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_audio_emitter.type has unexpected size % instead of 16", it.type.runtime_size);
                case "distance_model";
                    assert(it.offset_in_bytes == 48, "tg3_audio_emitter.distance_model has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3_audio_emitter.distance_model has unexpected size % instead of 16", it.type.runtime_size);
                case "positional";
                    assert(it.offset_in_bytes == 64, "tg3_audio_emitter.positional has unexpected offset % instead of 64", it.offset_in_bytes);
                    assert(it.type.runtime_size == 104, "tg3_audio_emitter.positional has unexpected size % instead of 104", it.type.runtime_size);
                case "source";
                    assert(it.offset_in_bytes == 168, "tg3_audio_emitter.source has unexpected offset % instead of 168", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_audio_emitter.source has unexpected size % instead of 4", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 176, "tg3_audio_emitter.ext has unexpected offset % instead of 176", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_audio_emitter.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_audio_emitter) == 232, "tg3_audio_emitter has size % instead of 232", size_of(tg3_audio_emitter));
    }

    {
        info := type_info(tg3_model);
        for info.members {
            if it.name == {
                case "arena_";
                    assert(it.offset_in_bytes == 0, "tg3_model.arena_ has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.arena_ has unexpected size % instead of 8", it.type.runtime_size);
                case "accessors";
                    assert(it.offset_in_bytes == 8, "tg3_model.accessors has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.accessors has unexpected size % instead of 8", it.type.runtime_size);
                case "accessors_count";
                    assert(it.offset_in_bytes == 16, "tg3_model.accessors_count has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.accessors_count has unexpected size % instead of 4", it.type.runtime_size);
                case "animations";
                    assert(it.offset_in_bytes == 24, "tg3_model.animations has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.animations has unexpected size % instead of 8", it.type.runtime_size);
                case "animations_count";
                    assert(it.offset_in_bytes == 32, "tg3_model.animations_count has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.animations_count has unexpected size % instead of 4", it.type.runtime_size);
                case "buffers";
                    assert(it.offset_in_bytes == 40, "tg3_model.buffers has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.buffers has unexpected size % instead of 8", it.type.runtime_size);
                case "buffers_count";
                    assert(it.offset_in_bytes == 48, "tg3_model.buffers_count has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.buffers_count has unexpected size % instead of 4", it.type.runtime_size);
                case "buffer_views";
                    assert(it.offset_in_bytes == 56, "tg3_model.buffer_views has unexpected offset % instead of 56", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.buffer_views has unexpected size % instead of 8", it.type.runtime_size);
                case "buffer_views_count";
                    assert(it.offset_in_bytes == 64, "tg3_model.buffer_views_count has unexpected offset % instead of 64", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.buffer_views_count has unexpected size % instead of 4", it.type.runtime_size);
                case "materials";
                    assert(it.offset_in_bytes == 72, "tg3_model.materials has unexpected offset % instead of 72", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.materials has unexpected size % instead of 8", it.type.runtime_size);
                case "materials_count";
                    assert(it.offset_in_bytes == 80, "tg3_model.materials_count has unexpected offset % instead of 80", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.materials_count has unexpected size % instead of 4", it.type.runtime_size);
                case "meshes";
                    assert(it.offset_in_bytes == 88, "tg3_model.meshes has unexpected offset % instead of 88", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.meshes has unexpected size % instead of 8", it.type.runtime_size);
                case "meshes_count";
                    assert(it.offset_in_bytes == 96, "tg3_model.meshes_count has unexpected offset % instead of 96", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.meshes_count has unexpected size % instead of 4", it.type.runtime_size);
                case "nodes";
                    assert(it.offset_in_bytes == 104, "tg3_model.nodes has unexpected offset % instead of 104", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.nodes has unexpected size % instead of 8", it.type.runtime_size);
                case "nodes_count";
                    assert(it.offset_in_bytes == 112, "tg3_model.nodes_count has unexpected offset % instead of 112", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.nodes_count has unexpected size % instead of 4", it.type.runtime_size);
                case "textures";
                    assert(it.offset_in_bytes == 120, "tg3_model.textures has unexpected offset % instead of 120", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.textures has unexpected size % instead of 8", it.type.runtime_size);
                case "textures_count";
                    assert(it.offset_in_bytes == 128, "tg3_model.textures_count has unexpected offset % instead of 128", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.textures_count has unexpected size % instead of 4", it.type.runtime_size);
                case "images";
                    assert(it.offset_in_bytes == 136, "tg3_model.images has unexpected offset % instead of 136", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.images has unexpected size % instead of 8", it.type.runtime_size);
                case "images_count";
                    assert(it.offset_in_bytes == 144, "tg3_model.images_count has unexpected offset % instead of 144", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.images_count has unexpected size % instead of 4", it.type.runtime_size);
                case "skins";
                    assert(it.offset_in_bytes == 152, "tg3_model.skins has unexpected offset % instead of 152", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.skins has unexpected size % instead of 8", it.type.runtime_size);
                case "skins_count";
                    assert(it.offset_in_bytes == 160, "tg3_model.skins_count has unexpected offset % instead of 160", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.skins_count has unexpected size % instead of 4", it.type.runtime_size);
                case "samplers";
                    assert(it.offset_in_bytes == 168, "tg3_model.samplers has unexpected offset % instead of 168", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.samplers has unexpected size % instead of 8", it.type.runtime_size);
                case "samplers_count";
                    assert(it.offset_in_bytes == 176, "tg3_model.samplers_count has unexpected offset % instead of 176", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.samplers_count has unexpected size % instead of 4", it.type.runtime_size);
                case "cameras";
                    assert(it.offset_in_bytes == 184, "tg3_model.cameras has unexpected offset % instead of 184", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.cameras has unexpected size % instead of 8", it.type.runtime_size);
                case "cameras_count";
                    assert(it.offset_in_bytes == 192, "tg3_model.cameras_count has unexpected offset % instead of 192", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.cameras_count has unexpected size % instead of 4", it.type.runtime_size);
                case "scenes";
                    assert(it.offset_in_bytes == 200, "tg3_model.scenes has unexpected offset % instead of 200", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.scenes has unexpected size % instead of 8", it.type.runtime_size);
                case "scenes_count";
                    assert(it.offset_in_bytes == 208, "tg3_model.scenes_count has unexpected offset % instead of 208", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.scenes_count has unexpected size % instead of 4", it.type.runtime_size);
                case "lights";
                    assert(it.offset_in_bytes == 216, "tg3_model.lights has unexpected offset % instead of 216", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.lights has unexpected size % instead of 8", it.type.runtime_size);
                case "lights_count";
                    assert(it.offset_in_bytes == 224, "tg3_model.lights_count has unexpected offset % instead of 224", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.lights_count has unexpected size % instead of 4", it.type.runtime_size);
                case "audio_emitters";
                    assert(it.offset_in_bytes == 232, "tg3_model.audio_emitters has unexpected offset % instead of 232", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.audio_emitters has unexpected size % instead of 8", it.type.runtime_size);
                case "audio_emitters_count";
                    assert(it.offset_in_bytes == 240, "tg3_model.audio_emitters_count has unexpected offset % instead of 240", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.audio_emitters_count has unexpected size % instead of 4", it.type.runtime_size);
                case "audio_sources";
                    assert(it.offset_in_bytes == 248, "tg3_model.audio_sources has unexpected offset % instead of 248", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.audio_sources has unexpected size % instead of 8", it.type.runtime_size);
                case "audio_sources_count";
                    assert(it.offset_in_bytes == 256, "tg3_model.audio_sources_count has unexpected offset % instead of 256", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.audio_sources_count has unexpected size % instead of 4", it.type.runtime_size);
                case "default_scene";
                    assert(it.offset_in_bytes == 260, "tg3_model.default_scene has unexpected offset % instead of 260", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.default_scene has unexpected size % instead of 4", it.type.runtime_size);
                case "extensions_used";
                    assert(it.offset_in_bytes == 264, "tg3_model.extensions_used has unexpected offset % instead of 264", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.extensions_used has unexpected size % instead of 8", it.type.runtime_size);
                case "extensions_used_count";
                    assert(it.offset_in_bytes == 272, "tg3_model.extensions_used_count has unexpected offset % instead of 272", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.extensions_used_count has unexpected size % instead of 4", it.type.runtime_size);
                case "extensions_required";
                    assert(it.offset_in_bytes == 280, "tg3_model.extensions_required has unexpected offset % instead of 280", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_model.extensions_required has unexpected size % instead of 8", it.type.runtime_size);
                case "extensions_required_count";
                    assert(it.offset_in_bytes == 288, "tg3_model.extensions_required_count has unexpected offset % instead of 288", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_model.extensions_required_count has unexpected size % instead of 4", it.type.runtime_size);
                case "asset";
                    assert(it.offset_in_bytes == 296, "tg3_model.asset has unexpected offset % instead of 296", it.offset_in_bytes);
                    assert(it.type.runtime_size == 120, "tg3_model.asset has unexpected size % instead of 120", it.type.runtime_size);
                case "ext";
                    assert(it.offset_in_bytes == 416, "tg3_model.ext has unexpected offset % instead of 416", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_model.ext has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_model) == 472, "tg3_model has size % instead of 472", size_of(tg3_model));
    }

    {
        info := type_info(tg3_fs_callbacks);
        for info.members {
            if it.name == {
                case "file_exists";
                    assert(it.offset_in_bytes == 0, "tg3_fs_callbacks.file_exists has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_fs_callbacks.file_exists has unexpected size % instead of 8", it.type.runtime_size);
                case "read_file";
                    assert(it.offset_in_bytes == 8, "tg3_fs_callbacks.read_file has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_fs_callbacks.read_file has unexpected size % instead of 8", it.type.runtime_size);
                case "free_file";
                    assert(it.offset_in_bytes == 16, "tg3_fs_callbacks.free_file has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_fs_callbacks.free_file has unexpected size % instead of 8", it.type.runtime_size);
                case "write_file";
                    assert(it.offset_in_bytes == 24, "tg3_fs_callbacks.write_file has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_fs_callbacks.write_file has unexpected size % instead of 8", it.type.runtime_size);
                case "resolve_path";
                    assert(it.offset_in_bytes == 32, "tg3_fs_callbacks.resolve_path has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_fs_callbacks.resolve_path has unexpected size % instead of 8", it.type.runtime_size);
                case "get_file_size";
                    assert(it.offset_in_bytes == 40, "tg3_fs_callbacks.get_file_size has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_fs_callbacks.get_file_size has unexpected size % instead of 8", it.type.runtime_size);
                case "user_data";
                    assert(it.offset_in_bytes == 48, "tg3_fs_callbacks.user_data has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_fs_callbacks.user_data has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_fs_callbacks) == 56, "tg3_fs_callbacks has size % instead of 56", size_of(tg3_fs_callbacks));
    }

    {
        info := type_info(tg3_image_request);
        for info.members {
            if it.name == {
                case "data";
                    assert(it.offset_in_bytes == 0, "tg3_image_request.data has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_image_request.data has unexpected size % instead of 8", it.type.runtime_size);
                case "data_size";
                    assert(it.offset_in_bytes == 8, "tg3_image_request.data_size has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_image_request.data_size has unexpected size % instead of 8", it.type.runtime_size);
                case "image_index";
                    assert(it.offset_in_bytes == 16, "tg3_image_request.image_index has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image_request.image_index has unexpected size % instead of 4", it.type.runtime_size);
                case "req_width";
                    assert(it.offset_in_bytes == 20, "tg3_image_request.req_width has unexpected offset % instead of 20", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image_request.req_width has unexpected size % instead of 4", it.type.runtime_size);
                case "req_height";
                    assert(it.offset_in_bytes == 24, "tg3_image_request.req_height has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image_request.req_height has unexpected size % instead of 4", it.type.runtime_size);
                case "mime_type";
                    assert(it.offset_in_bytes == 32, "tg3_image_request.mime_type has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_image_request.mime_type has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_image_request) == 40, "tg3_image_request has size % instead of 40", size_of(tg3_image_request));
    }

    {
        info := type_info(tg3_image_result);
        for info.members {
            if it.name == {
                case "pixels";
                    assert(it.offset_in_bytes == 0, "tg3_image_result.pixels has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_image_result.pixels has unexpected size % instead of 8", it.type.runtime_size);
                case "width";
                    assert(it.offset_in_bytes == 8, "tg3_image_result.width has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image_result.width has unexpected size % instead of 4", it.type.runtime_size);
                case "height";
                    assert(it.offset_in_bytes == 12, "tg3_image_result.height has unexpected offset % instead of 12", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image_result.height has unexpected size % instead of 4", it.type.runtime_size);
                case "component";
                    assert(it.offset_in_bytes == 16, "tg3_image_result.component has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image_result.component has unexpected size % instead of 4", it.type.runtime_size);
                case "bits";
                    assert(it.offset_in_bytes == 20, "tg3_image_result.bits has unexpected offset % instead of 20", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image_result.bits has unexpected size % instead of 4", it.type.runtime_size);
                case "pixel_type";
                    assert(it.offset_in_bytes == 24, "tg3_image_result.pixel_type has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_image_result.pixel_type has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_image_result) == 32, "tg3_image_result has size % instead of 32", size_of(tg3_image_result));
    }

    {
        info := type_info(tg3_image_callbacks);
        for info.members {
            if it.name == {
                case "load_image";
                    assert(it.offset_in_bytes == 0, "tg3_image_callbacks.load_image has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_image_callbacks.load_image has unexpected size % instead of 8", it.type.runtime_size);
                case "free_image";
                    assert(it.offset_in_bytes == 8, "tg3_image_callbacks.free_image has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_image_callbacks.free_image has unexpected size % instead of 8", it.type.runtime_size);
                case "user_data";
                    assert(it.offset_in_bytes == 16, "tg3_image_callbacks.user_data has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_image_callbacks.user_data has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_image_callbacks) == 24, "tg3_image_callbacks has size % instead of 24", size_of(tg3_image_callbacks));
    }

    {
        info := type_info(tg3_uri_callbacks);
        for info.members {
            if it.name == {
                case "encode";
                    assert(it.offset_in_bytes == 0, "tg3_uri_callbacks.encode has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_uri_callbacks.encode has unexpected size % instead of 8", it.type.runtime_size);
                case "decode";
                    assert(it.offset_in_bytes == 8, "tg3_uri_callbacks.decode has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_uri_callbacks.decode has unexpected size % instead of 8", it.type.runtime_size);
                case "user_data";
                    assert(it.offset_in_bytes == 16, "tg3_uri_callbacks.user_data has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_uri_callbacks.user_data has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_uri_callbacks) == 24, "tg3_uri_callbacks has size % instead of 24", size_of(tg3_uri_callbacks));
    }

    {
        info := type_info(tg3_stream_callbacks);
        for info.members {
            if it.name == {
                case "on_asset";
                    assert(it.offset_in_bytes == 0, "tg3_stream_callbacks.on_asset has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_asset has unexpected size % instead of 8", it.type.runtime_size);
                case "on_buffer";
                    assert(it.offset_in_bytes == 8, "tg3_stream_callbacks.on_buffer has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_buffer has unexpected size % instead of 8", it.type.runtime_size);
                case "on_buffer_view";
                    assert(it.offset_in_bytes == 16, "tg3_stream_callbacks.on_buffer_view has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_buffer_view has unexpected size % instead of 8", it.type.runtime_size);
                case "on_accessor";
                    assert(it.offset_in_bytes == 24, "tg3_stream_callbacks.on_accessor has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_accessor has unexpected size % instead of 8", it.type.runtime_size);
                case "on_mesh";
                    assert(it.offset_in_bytes == 32, "tg3_stream_callbacks.on_mesh has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_mesh has unexpected size % instead of 8", it.type.runtime_size);
                case "on_node";
                    assert(it.offset_in_bytes == 40, "tg3_stream_callbacks.on_node has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_node has unexpected size % instead of 8", it.type.runtime_size);
                case "on_material";
                    assert(it.offset_in_bytes == 48, "tg3_stream_callbacks.on_material has unexpected offset % instead of 48", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_material has unexpected size % instead of 8", it.type.runtime_size);
                case "on_texture";
                    assert(it.offset_in_bytes == 56, "tg3_stream_callbacks.on_texture has unexpected offset % instead of 56", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_texture has unexpected size % instead of 8", it.type.runtime_size);
                case "on_image";
                    assert(it.offset_in_bytes == 64, "tg3_stream_callbacks.on_image has unexpected offset % instead of 64", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_image has unexpected size % instead of 8", it.type.runtime_size);
                case "on_sampler";
                    assert(it.offset_in_bytes == 72, "tg3_stream_callbacks.on_sampler has unexpected offset % instead of 72", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_sampler has unexpected size % instead of 8", it.type.runtime_size);
                case "on_animation";
                    assert(it.offset_in_bytes == 80, "tg3_stream_callbacks.on_animation has unexpected offset % instead of 80", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_animation has unexpected size % instead of 8", it.type.runtime_size);
                case "on_skin";
                    assert(it.offset_in_bytes == 88, "tg3_stream_callbacks.on_skin has unexpected offset % instead of 88", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_skin has unexpected size % instead of 8", it.type.runtime_size);
                case "on_camera";
                    assert(it.offset_in_bytes == 96, "tg3_stream_callbacks.on_camera has unexpected offset % instead of 96", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_camera has unexpected size % instead of 8", it.type.runtime_size);
                case "on_scene";
                    assert(it.offset_in_bytes == 104, "tg3_stream_callbacks.on_scene has unexpected offset % instead of 104", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_scene has unexpected size % instead of 8", it.type.runtime_size);
                case "on_light";
                    assert(it.offset_in_bytes == 112, "tg3_stream_callbacks.on_light has unexpected offset % instead of 112", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.on_light has unexpected size % instead of 8", it.type.runtime_size);
                case "user_data";
                    assert(it.offset_in_bytes == 120, "tg3_stream_callbacks.user_data has unexpected offset % instead of 120", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_stream_callbacks.user_data has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_stream_callbacks) == 128, "tg3_stream_callbacks has size % instead of 128", size_of(tg3_stream_callbacks));
    }

    {
        info := type_info(tg3_progress_info);
        for info.members {
            if it.name == {
                case "bytes_processed";
                    assert(it.offset_in_bytes == 0, "tg3_progress_info.bytes_processed has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_progress_info.bytes_processed has unexpected size % instead of 8", it.type.runtime_size);
                case "bytes_total";
                    assert(it.offset_in_bytes == 8, "tg3_progress_info.bytes_total has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_progress_info.bytes_total has unexpected size % instead of 8", it.type.runtime_size);
                case "elements_parsed";
                    assert(it.offset_in_bytes == 16, "tg3_progress_info.elements_parsed has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_progress_info.elements_parsed has unexpected size % instead of 4", it.type.runtime_size);
                case "current_section";
                    assert(it.offset_in_bytes == 24, "tg3_progress_info.current_section has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_progress_info.current_section has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_progress_info) == 32, "tg3_progress_info has size % instead of 32", size_of(tg3_progress_info));
    }

    {
        info := type_info(tg3_memory_config);
        for info.members {
            if it.name == {
                case "memory_budget";
                    assert(it.offset_in_bytes == 0, "tg3_memory_config.memory_budget has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_memory_config.memory_budget has unexpected size % instead of 8", it.type.runtime_size);
                case "max_single_alloc";
                    assert(it.offset_in_bytes == 8, "tg3_memory_config.max_single_alloc has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_memory_config.max_single_alloc has unexpected size % instead of 8", it.type.runtime_size);
                case "arena_block_size";
                    assert(it.offset_in_bytes == 16, "tg3_memory_config.arena_block_size has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_memory_config.arena_block_size has unexpected size % instead of 4", it.type.runtime_size);
                case "allocator";
                    assert(it.offset_in_bytes == 24, "tg3_memory_config.allocator has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 32, "tg3_memory_config.allocator has unexpected size % instead of 32", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_memory_config) == 56, "tg3_memory_config has size % instead of 56", size_of(tg3_memory_config));
    }

    {
        info := type_info(tg3_parse_options);
        for info.members {
            if it.name == {
                case "required_sections";
                    assert(it.offset_in_bytes == 0, "tg3_parse_options.required_sections has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_parse_options.required_sections has unexpected size % instead of 4", it.type.runtime_size);
                case "strictness";
                    assert(it.offset_in_bytes == 4, "tg3_parse_options.strictness has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_parse_options.strictness has unexpected size % instead of 4", it.type.runtime_size);
                case "memory";
                    assert(it.offset_in_bytes == 8, "tg3_parse_options.memory has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_parse_options.memory has unexpected size % instead of 56", it.type.runtime_size);
                case "fs";
                    assert(it.offset_in_bytes == 64, "tg3_parse_options.fs has unexpected offset % instead of 64", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_parse_options.fs has unexpected size % instead of 56", it.type.runtime_size);
                case "uri";
                    assert(it.offset_in_bytes == 120, "tg3_parse_options.uri has unexpected offset % instead of 120", it.offset_in_bytes);
                    assert(it.type.runtime_size == 24, "tg3_parse_options.uri has unexpected size % instead of 24", it.type.runtime_size);
                case "image";
                    assert(it.offset_in_bytes == 144, "tg3_parse_options.image has unexpected offset % instead of 144", it.offset_in_bytes);
                    assert(it.type.runtime_size == 24, "tg3_parse_options.image has unexpected size % instead of 24", it.type.runtime_size);
                case "stream";
                    assert(it.offset_in_bytes == 168, "tg3_parse_options.stream has unexpected offset % instead of 168", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_parse_options.stream has unexpected size % instead of 8", it.type.runtime_size);
                case "progress";
                    assert(it.offset_in_bytes == 176, "tg3_parse_options.progress has unexpected offset % instead of 176", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_parse_options.progress has unexpected size % instead of 8", it.type.runtime_size);
                case "progress_user_data";
                    assert(it.offset_in_bytes == 184, "tg3_parse_options.progress_user_data has unexpected offset % instead of 184", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_parse_options.progress_user_data has unexpected size % instead of 8", it.type.runtime_size);
                case "images_as_is";
                    assert(it.offset_in_bytes == 192, "tg3_parse_options.images_as_is has unexpected offset % instead of 192", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_parse_options.images_as_is has unexpected size % instead of 4", it.type.runtime_size);
                case "preserve_image_channels";
                    assert(it.offset_in_bytes == 196, "tg3_parse_options.preserve_image_channels has unexpected offset % instead of 196", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_parse_options.preserve_image_channels has unexpected size % instead of 4", it.type.runtime_size);
                case "store_original_json";
                    assert(it.offset_in_bytes == 200, "tg3_parse_options.store_original_json has unexpected offset % instead of 200", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_parse_options.store_original_json has unexpected size % instead of 4", it.type.runtime_size);
                case "skip_extras_values";
                    assert(it.offset_in_bytes == 204, "tg3_parse_options.skip_extras_values has unexpected offset % instead of 204", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_parse_options.skip_extras_values has unexpected size % instead of 4", it.type.runtime_size);
                case "borrow_input_buffers";
                    assert(it.offset_in_bytes == 208, "tg3_parse_options.borrow_input_buffers has unexpected offset % instead of 208", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_parse_options.borrow_input_buffers has unexpected size % instead of 4", it.type.runtime_size);
                case "parse_float32";
                    assert(it.offset_in_bytes == 212, "tg3_parse_options.parse_float32 has unexpected offset % instead of 212", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_parse_options.parse_float32 has unexpected size % instead of 4", it.type.runtime_size);
                case "validate_indices";
                    assert(it.offset_in_bytes == 216, "tg3_parse_options.validate_indices has unexpected offset % instead of 216", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_parse_options.validate_indices has unexpected size % instead of 4", it.type.runtime_size);
                case "max_external_file_size";
                    assert(it.offset_in_bytes == 224, "tg3_parse_options.max_external_file_size has unexpected offset % instead of 224", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3_parse_options.max_external_file_size has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_parse_options) == 232, "tg3_parse_options has size % instead of 232", size_of(tg3_parse_options));
    }

    {
        info := type_info(tg3_write_options);
        for info.members {
            if it.name == {
                case "pretty_print";
                    assert(it.offset_in_bytes == 0, "tg3_write_options.pretty_print has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_write_options.pretty_print has unexpected size % instead of 4", it.type.runtime_size);
                case "write_binary";
                    assert(it.offset_in_bytes == 4, "tg3_write_options.write_binary has unexpected offset % instead of 4", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_write_options.write_binary has unexpected size % instead of 4", it.type.runtime_size);
                case "embed_images";
                    assert(it.offset_in_bytes == 8, "tg3_write_options.embed_images has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_write_options.embed_images has unexpected size % instead of 4", it.type.runtime_size);
                case "embed_buffers";
                    assert(it.offset_in_bytes == 12, "tg3_write_options.embed_buffers has unexpected offset % instead of 12", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_write_options.embed_buffers has unexpected size % instead of 4", it.type.runtime_size);
                case "serialize_defaults";
                    assert(it.offset_in_bytes == 16, "tg3_write_options.serialize_defaults has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3_write_options.serialize_defaults has unexpected size % instead of 4", it.type.runtime_size);
                case "fs";
                    assert(it.offset_in_bytes == 24, "tg3_write_options.fs has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_write_options.fs has unexpected size % instead of 56", it.type.runtime_size);
                case "uri";
                    assert(it.offset_in_bytes == 80, "tg3_write_options.uri has unexpected offset % instead of 80", it.offset_in_bytes);
                    assert(it.type.runtime_size == 24, "tg3_write_options.uri has unexpected size % instead of 24", it.type.runtime_size);
                case "memory";
                    assert(it.offset_in_bytes == 104, "tg3_write_options.memory has unexpected offset % instead of 104", it.offset_in_bytes);
                    assert(it.type.runtime_size == 56, "tg3_write_options.memory has unexpected size % instead of 56", it.type.runtime_size);
            }
        }
        assert(size_of(tg3_write_options) == 160, "tg3_write_options has size % instead of 160", size_of(tg3_write_options));
    }

    {
        info := type_info(tg3json_string);
        for info.members {
            if it.name == {
                case "ptr";
                    assert(it.offset_in_bytes == 0, "tg3json_string.ptr has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3json_string.ptr has unexpected size % instead of 8", it.type.runtime_size);
                case "len";
                    assert(it.offset_in_bytes == 8, "tg3json_string.len has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3json_string.len has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3json_string) == 16, "tg3json_string has size % instead of 16", size_of(tg3json_string));
    }

    {
        info := type_info(tg3json_array);
        for info.members {
            if it.name == {
                case "items";
                    assert(it.offset_in_bytes == 0, "tg3json_array.items has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3json_array.items has unexpected size % instead of 8", it.type.runtime_size);
                case "count";
                    assert(it.offset_in_bytes == 8, "tg3json_array.count has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3json_array.count has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3json_array) == 16, "tg3json_array has size % instead of 16", size_of(tg3json_array));
    }

    {
        info := type_info(tg3json_object_entry);
        for info.members {
            if it.name == {
                case "key";
                    assert(it.offset_in_bytes == 0, "tg3json_object_entry.key has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3json_object_entry.key has unexpected size % instead of 8", it.type.runtime_size);
                case "key_len";
                    assert(it.offset_in_bytes == 8, "tg3json_object_entry.key_len has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3json_object_entry.key_len has unexpected size % instead of 8", it.type.runtime_size);
                case "value";
                    assert(it.offset_in_bytes == 16, "tg3json_object_entry.value has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3json_object_entry.value has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3json_object_entry) == 24, "tg3json_object_entry has size % instead of 24", size_of(tg3json_object_entry));
    }

    {
        info := type_info(tg3json_object);
        for info.members {
            if it.name == {
                case "items";
                    assert(it.offset_in_bytes == 0, "tg3json_object.items has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3json_object.items has unexpected size % instead of 8", it.type.runtime_size);
                case "count";
                    assert(it.offset_in_bytes == 8, "tg3json_object.count has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3json_object.count has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(tg3json_object) == 16, "tg3json_object has size % instead of 16", size_of(tg3json_object));
    }

    {
        info := type_info(tg3json_value);
        for info.members {
            if it.name == {
                case "type";
                    assert(it.offset_in_bytes == 0, "tg3json_value.type has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3json_value.type has unexpected size % instead of 4", it.type.runtime_size);
                case "u";
                    assert(it.offset_in_bytes == 8, "tg3json_value.u has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 16, "tg3json_value.u has unexpected size % instead of 16", it.type.runtime_size);
            }
        }
        assert(size_of(tg3json_value) == 24, "tg3json_value has size % instead of 24", size_of(tg3json_value));
    }

    {
        info := type_info(tg3json_parse_options);
        for info.members {
            if it.name == {
                case "depth_limit";
                    assert(it.offset_in_bytes == 0, "tg3json_parse_options.depth_limit has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3json_parse_options.depth_limit has unexpected size % instead of 8", it.type.runtime_size);
                case "memory_budget";
                    assert(it.offset_in_bytes == 8, "tg3json_parse_options.memory_budget has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3json_parse_options.memory_budget has unexpected size % instead of 8", it.type.runtime_size);
                case "max_single_alloc";
                    assert(it.offset_in_bytes == 16, "tg3json_parse_options.max_single_alloc has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3json_parse_options.max_single_alloc has unexpected size % instead of 8", it.type.runtime_size);
                case "max_string_length";
                    assert(it.offset_in_bytes == 24, "tg3json_parse_options.max_string_length has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "tg3json_parse_options.max_string_length has unexpected size % instead of 8", it.type.runtime_size);
                case "parse_float32";
                    assert(it.offset_in_bytes == 32, "tg3json_parse_options.parse_float32 has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "tg3json_parse_options.parse_float32 has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(tg3json_parse_options) == 40, "tg3json_parse_options has size % instead of 40", size_of(tg3json_parse_options));
    }
}

