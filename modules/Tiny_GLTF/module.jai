#module_parameters()(DEBUG := false);

Uri_Encode_Fn :: #type (out: *u8, out_cap: u32, out_len: *u32, uri: *u8, uri_len: u32, obj_type: *u8, user_data: *void) -> s32 #c_call;
Uri_Decode_Fn :: #type (out: *u8, out_cap: u32, out_len: *u32, uri: *u8, uri_len: u32, user_data: *void) -> s32 #c_call;

Progress_Fn :: #type (info: *Progress_Info, user_data: *void) -> s32 #c_call;

On_Asset_Fn :: #type (a: *Asset, ud: *void) -> Stream_Action #c_call;
On_Buffer_Fn :: #type (b: *Buffer, idx: s32, ud: *void) -> Stream_Action #c_call;
On_Buffer_View_Fn :: #type (bv: *Buffer_View, idx: s32, ud: *void) -> Stream_Action #c_call;
On_Accessor_Fn :: #type (a: *Accessor, idx: s32, ud: *void) -> Stream_Action #c_call;
On_Mesh_Fn :: #type (m: *Mesh, idx: s32, ud: *void) -> Stream_Action #c_call;
On_Node_Fn :: #type (n: *Node, idx: s32, ud: *void) -> Stream_Action #c_call;
On_Material_Fn :: #type (m: *Material, idx: s32, ud: *void) -> Stream_Action #c_call;
On_Texture_Fn :: #type (t: *Texture, idx: s32, ud: *void) -> Stream_Action #c_call;
On_Image_Fn :: #type (img: *Image, idx: s32, ud: *void) -> Stream_Action #c_call;
On_Sampler_Fn :: #type (s: *Sampler, idx: s32, ud: *void) -> Stream_Action #c_call;
On_Animation_Fn :: #type (a: *Animation, idx: s32, ud: *void) -> Stream_Action #c_call;
On_Skin_Fn :: #type (s: *Skin, idx: s32, ud: *void) -> Stream_Action #c_call;
On_Camera_Fn :: #type (c: *Camera, idx: s32, ud: *void) -> Stream_Action #c_call;
On_Scene_Fn :: #type (s: *Scene, idx: s32, ud: *void) -> Stream_Action #c_call;
On_Light_Fn :: #type (l: *Light, idx: s32, ud: *void) -> Stream_Action #c_call;

Load_Image_Fn :: #type (result: *Image_Result, request: *Image_Request, user_data: *void) -> s32 #c_call;
Free_Image_Fn :: #type (pixels: *u8, user_data: *void) -> void #c_call;

File_Exists_Fn :: #type (path: *u8, path_len: u32, user_data: *void) -> s32 #c_call;
Read_File_Fn :: #type (out_data: **u8, out_size: *u64, path: *u8, path_len: u32, user_data: *void) -> s32 #c_call;
Free_File_Fn :: #type (data: *u8, size: u64, user_data: *void) -> void #c_call;
Write_File_Fn :: #type (path: *u8, path_len: u32, data: *u8, size: u64, user_data: *void) -> s32 #c_call;
Resolve_Path_Fn :: #type (out_path: *u8, out_cap: u32, out_len: *u32, path: *u8, path_len: u32, user_data: *void) -> s32 #c_call;
Get_File_Size_Fn :: #type (out_size: *u64, path: *u8, path_len: u32, user_data: *void) -> s32 #c_call;

Parse_Options :: struct {
    required_sections:       u32;
    strictness:              Strictness;
    memory:                  Memory_Config;

    fs:                      Fs_Callbacks;
    uri:                     Uri_Callbacks;
    image:                   Image_Callbacks;
    stream:                  *Stream_Callbacks;
    progress:                Progress_Fn;
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

Uri_Callbacks :: struct {
    encode:    Uri_Encode_Fn;
    decode:    Uri_Decode_Fn;
    user_data: *void;
}

Stream_Callbacks :: struct {
    on_asset:       On_Asset_Fn;
    on_buffer:      On_Buffer_Fn;
    on_buffer_view: On_Buffer_View_Fn;
    on_accessor:    On_Accessor_Fn;
    on_mesh:        On_Mesh_Fn;
    on_node:        On_Node_Fn;
    on_material:    On_Material_Fn;
    on_texture:     On_Texture_Fn;
    on_image:       On_Image_Fn;
    on_sampler:     On_Sampler_Fn;
    on_animation:   On_Animation_Fn;
    on_skin:        On_Skin_Fn;
    on_camera:      On_Camera_Fn;
    on_scene:       On_Scene_Fn;
    on_light:       On_Light_Fn;
    user_data:      *void;
}

Progress_Info :: struct {
    bytes_processed: u64;
    bytes_total:     u64;
    elements_parsed: u32;
    current_section: *u8;
}

Memory_Config :: struct {
    memory_budget:    u64;
    max_single_alloc: u64;
    arena_block_size: u32;
    allocator:        Allocator;
}

Texture :: struct {
    name:    Str;
    sampler: s32;
    source:  s32;
    ext:     Extras_Ext;
}

Str :: struct {
    data: *u8;
    len:  u32;
}

Skin :: struct {
    name:                  Str;
    inverse_bind_matrices: s32;
    skeleton:              s32;
    joints:                *s32;
    joints_count:          u32;
    ext:                   Extras_Ext;
}

Scene :: struct {
    name:                 Str;
    nodes:                *s32;
    nodes_count:          u32;
    audio_emitters:       *s32;
    audio_emitters_count: u32;
    ext:                  Extras_Ext;
}

Sampler :: struct {
    name:       Str;
    min_filter: s32;
    mag_filter: s32;
    wrap_s:     s32;
    wrap_t:     s32;
    ext:        Extras_Ext;
}

Node :: struct {
    name:           Str;
    camera:         s32;
    skin:           s32;
    mesh:           s32;
    light:          s32;
    emitter:        s32;

    lods:           *s32;
    lods_count:     u32;
    children:       *s32;
    children_count: u32;

    rotation:       [4] float64;
    scale:          [3] float64;
    translation:    [3] float64;
    matrix:         [16] float64;
    has_matrix:     s32;

    weights:        *float64;
    weights_count:  u32;

    ext:            Extras_Ext;
}

Mesh :: struct {
    name:             Str;
    primitives:       *Primitive;
    primitives_count: u32;
    weights:          *float64;
    weights_count:    u32;
    ext:              Extras_Ext;
}

Primitive :: struct {
    attributes:              *Str_Int_Pair;
    attributes_count:        u32;
    material:                s32;
    indices:                 s32;
    mode:                    s32;

    targets:                 **Str_Int_Pair;
    target_attribute_counts: *u32;
    targets_count:           u32;

    ext:                     Extras_Ext;
}

Str_Int_Pair :: struct {
    key:   Str;
    value: s32;
}

Material :: struct {
    name:                   Str;
    emissive_factor:        [3] float64; /* Default: {0,0,0} */
    alpha_mode:             Str; /* "OPAQUE","MASK","BLEND" */
    alpha_cutoff:           float64; /* Default: 0.5 */
    double_sided:           s32; /* 0 or 1 */
    lods:                   *s32;
    lods_count:             u32;
    pbr_metallic_roughness: Pbr_Metallic_Roughness;
    normal_texture:         Normal_Texture_Info;
    occlusion_texture:      Occlusion_Texture_Info;
    emissive_texture:       Texture_Info;
    ext:                    Extras_Ext;
}

Occlusion_Texture_Info :: struct {
    index:     s32;
    tex_coord: s32;
    strength:  float64;
    ext:       Extras_Ext;
}

Texture_Info :: struct {
    index:     s32;
    tex_coord: s32;
    ext:       Extras_Ext;
}

Pbr_Metallic_Roughness :: struct {
    base_color_factor:          [4]float64;
    base_color_texture:         Texture_Info;
    metallic_factor:            float64;
    roughness_factor:           float64;
    metallic_roughness_texture: Texture_Info;
    ext:                        Extras_Ext;
}

Normal_Texture_Info :: struct {
    index:     s32;
    tex_coord: s32;
    scale:     float64;
    ext:       Extras_Ext;
}

Light :: struct {
    name:      Str;
    color:     [3]float64;
    intensity: float64;
    type:      Str;
    range:     float64;
    spot:      Spot_Light;
    ext:       Extras_Ext;
}

Spot_Light :: struct {
    inner_cone_angle: float64;
    outer_cone_angle: float64;
    ext:              Extras_Ext;
}

Image_Callbacks :: struct {
    load_image: Load_Image_Fn;
    free_image: Free_Image_Fn;
    user_data:  *void;
}

Image :: struct {
    name:        Str;
    width:       s32;
    height:      s32;
    component:   s32;
    bits:        s32;
    pixel_type:  s32;
    image:       Span_u8;
    buffer_view: s32;
    mime_type:   Str;
    uri:         Str;
    as_is:       s32;
    ext:         Extras_Ext;
}

Span_u8 :: struct {
    data:  *u8;
    count: u64;
}

Fs_Callbacks :: struct {
    file_exists:   File_Exists_Fn;
    read_file:     Read_File_Fn;
    free_file:     Free_File_Fn;
    write_file:    Write_File_Fn;
    resolve_path:  Resolve_Path_Fn;
    get_file_size: Get_File_Size_Fn;
    user_data:     *void;
}

Image_Result :: struct {
    pixels:     *u8;
    width:      s32;
    height:     s32;
    component:  s32;
    bits:       s32;
    pixel_type: s32;
}

Image_Request :: struct {
    data:        *u8;
    data_size:   u64;
    image_index: s32;
    req_width:   s32;
    req_height:  s32;
    mime_type:   *u8;
}

Extras_Ext :: struct {
    extras:           *Value;
    extensions:       *Extension;
    extensions_count: u32;
    extras_json:      Str;
    extensions_json:  Str;
}

Extension :: struct {
    name:  Str;
    value: Value;
}

Value :: struct {
    type:         Value_Type;
    struct {
        int_val: s64; // largest member, moved to the start of the struct/union to support #overlay.

        #overlay (int_val) bool_val: s32;
        #overlay (int_val) real_val: float64;
    }

    string_val:   Str;
    array_data:   *Value;
    array_count:  u32;
    object_data:  *Kv_Pair;
    object_count: u32;
    binary_val:   Span_u8;
}

Kv_Pair :: struct {
    key:   Str;
    value: Value;
}

Camera :: struct {
    name:         Str;
    type:         Str;
    perspective:  Perspective_Camera;
    orthographic: Orthographic_Camera;
    ext:          Extras_Ext;
}

Perspective_Camera :: struct {
    aspect_ratio: float64;
    yfov:         float64;
    zfar:         float64;
    znear:        float64;
    ext:          Extras_Ext;
}

Orthographic_Camera :: struct {
    xmag:  float64;
    ymag:  float64;
    zfar:  float64;
    znear: float64;
    ext:   Extras_Ext;
}

Buffer_View :: struct {
    name:          Str;
    buffer:        s32;
    byte_offset:   u64;
    byte_length:   u64;
    byte_stride:   u32;
    target:        s32;
    draco_decoded: s32;
    ext:           Extras_Ext;
}

Buffer :: struct {
    name:        Str;
    byte_length: u64; /* Declared buffer.byteLength */
    data:        Span_u8;
    uri:         Str;
    ext:         Extras_Ext;
}

Asset :: struct {
    version:     Str;
    generator:   Str;
    min_version: Str;
    copyright:   Str;
    ext:         Extras_Ext;
}

Animation :: struct {
    name:           Str;
    channels:       *Animation_Channel;
    channels_count: u32;
    samplers:       *Animation_Sampler;
    samplers_count: u32;
    ext:            Extras_Ext;
}

Animation_Channel :: struct {
    sampler: s32;
    target:  Animation_Channel_Target;
    ext:     Extras_Ext;
}

Animation_Sampler :: struct {
    input:         s32;
    output:        s32;
    interpolation: Str;
    ext:           Extras_Ext;
}

Animation_Channel_Target :: struct {
    node: s32;
    path: Str;
    ext:  Extras_Ext;
}

Accessor :: struct {
    name:             Str;
    buffer_view:      s32;
    byte_offset:      u64;
    normalized:       s32;
    component_type:   s32;
    count:            u64;
    type:             s32;
    min_values:       *float64;
    min_values_count: u32;
    max_values:       *float64;
    max_values_count: u32;
    sparse:           Accessor_Sparse;
    ext:              Extras_Ext;
}

Accessor_Sparse :: struct {
    count:     s32;
    is_sparse: s32;
    indices:   Accessor_Sparse_Indices;
    values:    Accessor_Sparse_Values;
    ext:       Extras_Ext;
}

Accessor_Sparse_Values :: struct {
    buffer_view: s32;
    byte_offset: u64;
    ext:         Extras_Ext;
}

Accessor_Sparse_Indices :: struct {
    byte_offset:    u64;
    buffer_view:    s32;
    component_type: s32;
    ext:            Extras_Ext;
}

Error_Stack :: struct {
    entries:   *Error_Entry;
    count:     u32;
    capacity:  u32;
    has_error: s32;
}

Error_Entry :: struct {
    severity:    Severity;
    code:        Error_Code;
    message:     *u8;
    json_path:   *u8;
    byte_offset: s64;
}

Model :: struct {
    arena_:                    *Arena;

    accessors:                 *Accessor;
    accessors_count:           u32;
    animations:                *Animation;
    animations_count:          u32;
    buffers:                   *Buffer;
    buffers_count:             u32;
    buffer_views:              *Buffer_View;
    buffer_views_count:        u32;
    materials:                 *Material;
    materials_count:           u32;
    meshes:                    *Mesh;
    meshes_count:              u32;
    nodes:                     *Node;
    nodes_count:               u32;
    textures:                  *Texture;
    textures_count:            u32;
    images:                    *Image;
    images_count:              u32;
    skins:                     *Skin;
    skins_count:               u32;
    samplers:                  *Sampler;
    samplers_count:            u32;
    cameras:                   *Camera;
    cameras_count:             u32;
    scenes:                    *Scene;
    scenes_count:              u32;
    lights:                    *Light;
    lights_count:              u32;
    audio_emitters:            *Audio_Emitter;
    audio_emitters_count:      u32;
    audio_sources:             *Audio_Source;
    audio_sources_count:       u32;

    default_scene:             s32;
    extensions_used:           *Str;
    extensions_used_count:     u32;
    extensions_required:       *Str;
    extensions_required_count: u32;
    asset:                     Asset;
    ext:                       Extras_Ext;
}

Audio_Emitter :: struct {
    name:           Str;
    gain:           float64;
    loop:           s32;
    playing:        s32;
    type:           Str;
    distance_model: Str;
    positional:     Positional_Emitter;
    source:         s32;
    ext:            Extras_Ext;
}

Positional_Emitter :: struct {
    cone_inner_angle: float64;
    cone_outer_angle: float64;
    cone_outer_gain:  float64;
    max_distance:     float64;
    ref_distance:     float64;
    rolloff_factor:   float64;
    ext:              Extras_Ext;
}

Audio_Source :: struct {
    name:        Str;
    uri:         Str;
    buffer_view: s32;
    mime_type:   Str;
    ext:         Extras_Ext;
}

Arena :: struct {}

Strictness :: enum u32 {
    PERMISSIVE :: 0;
    STRICT     :: 1;
}

Stream_Action :: enum u32 {
    CONTINUE :: 0;
    ABORT    :: 1;
    SKIP     :: 2;
}

Value_Type :: enum u32 {
    NULL   :: 0;
    BOOL   :: 1;
    INT    :: 2;
    REAL   :: 3;
    STRING :: 4;
    ARRAY  :: 5;
    BINARY :: 6;
    OBJECT :: 7;
}

Severity :: enum u32 {
    INFO    :: 0;
    WARNING :: 1;
    ERROR   :: 2;
}

Error_Code :: enum u32 {
    OK :: 0;

    FILE_NOT_FOUND :: 1;
    FILE_READ      :: 2;
    FILE_WRITE     :: 3;
    FILE_TOO_LARGE :: 4;

    JSON_PARSE         :: 10;
    JSON_TYPE_MISMATCH :: 11;
    JSON_MISSING_FIELD :: 12;
    JSON_INVALID_VALUE :: 13;

    GLB_INVALID_MAGIC   :: 20;
    GLB_INVALID_VERSION :: 21;
    GLB_INVALID_HEADER  :: 22;
    GLB_CHUNK_ERROR     :: 23;
    GLB_SIZE_MISMATCH   :: 24;

    MISSING_REQUIRED     :: 30;
    INVALID_INDEX        :: 31;
    INVALID_TYPE         :: 32;
    INVALID_VALUE        :: 33;
    INVALID_ACCESSOR     :: 34;
    INVALID_BUFFER       :: 35;
    INVALID_BUFFER_VIEW  :: 36;
    INVALID_IMAGE        :: 37;
    INVALID_MATERIAL     :: 38;
    INVALID_MESH         :: 39;
    INVALID_NODE         :: 40;
    INVALID_ANIMATION    :: 41;
    INVALID_SKIN         :: 42;
    INVALID_CAMERA       :: 43;
    INVALID_SCENE        :: 44;
    BUFFER_SIZE_MISMATCH :: 45;

    OUT_OF_MEMORY     :: 50;
    DATA_URI_DECODE   :: 51;
    BASE64_DECODE     :: 52;
    EXTERNAL_RESOURCE :: 53;
    IMAGE_DECODE      :: 54;

    CALLBACK_FAILED  :: 60;
    FS_NOT_AVAILABLE :: 61;

    STREAM_ABORTED :: 70;

    WRITE_FAILED     :: 80;
    SERIALIZE_FAILED :: 81;
}

Texture_Filter :: enum {
    NEAREST                :: 9728;
    LINEAR                 :: 9729;
    NEAREST_MIPMAP_NEAREST :: 9984;
    LINEAR_MIPMAP_NEAREST  :: 9985;
    NEAREST_MIPMAP_LINEAR  :: 9986;
    LINEAR_MIPMAP_LINEAR   :: 9987;
}

Texture_Wrap :: enum {
    REPEAT          :: 10497;
    CLAMP_TO_EDGE   :: 33071;
    MIRRORED_REPEAT :: 33648;
}

_Type :: enum {
    VEC2   :: 2;
    VEC3   :: 3;
    VEC4   :: 4;
    MAT2   :: 32 + 2;
    MAT3   :: 32 + 3;
    MAT4   :: 32 + 4;
    SCALAR :: 64 + 1;
    VECTOR :: 64 + 4;
    MATRIX :: 64 + 16;
}

Component_Type :: enum {
    BYTE           :: 5120;
    UNSIGNED_BYTE  :: 5121;
    SHORT          :: 5122;
    UNSIGNED_SHORT :: 5123;
    INT            :: 5124;
    UNSIGNED_INT   :: 5125;
    FLOAT          :: 5126;
    DOUBLE         :: 5130;
}

parse_options_init :: (options: *Parse_Options) -> void #foreign tinygltf "tg3_parse_options_init";

error_stack_init :: (es: *Error_Stack) -> void #foreign tinygltf "tg3_error_stack_init";
error_stack_free :: (es: *Error_Stack) -> void #foreign tinygltf "tg3_error_stack_free";

parse_file :: (
    model: *Model,
    errors: *Error_Stack,
    filename: *u8,
    filename_len: u32,
    options: *Parse_Options
) -> Error_Code #foreign tinygltf "tg3_parse_file";

model_free :: (model: *Model) -> void #foreign tinygltf "tg3_model_free";



#scope_file

#if OS == .LINUX {
    #if DEBUG {
        tinygltf :: #library,no_dll "./LINUX/tinygltf_debug";
    } else {
        tinygltf :: #library,no_dll "./LINUX/tinygltf";
    }
} else {
    #assert "Unsupported OS";
}
