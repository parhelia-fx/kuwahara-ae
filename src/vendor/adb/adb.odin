package adb

import "core:c"

AE_PLUG_IN_VERSION :: 13
AE_PLUG_IN_SUBVERS :: 28

MAX_EFFECT_NAME_LEN :: 31
MAX_EFFECT_MSG_LEN :: 255
MAX_EFFECT_PARAM_NAME_LEN :: 31
MAX_PARAM_VALUE_LEN :: 31
MAX_PARAM_DESCRIPTION_LEN :: 31

BUILD_BITS :: 0x1ff
BUILD_SHIFT :: 0
STAGE_BITS :: 0x3
STAGE_SHIFT :: 9
BUGFIX_BITS :: 0xf
BUGFIX_SHIFT :: 11
SUBVERS_BITS :: 0xf
SUBVERS_SHIFT :: 15
VERS_BITS :: 0x7
VERS_SHIFT :: 19
VERS_HIGH_BITS :: 0xf
VERS_HIGH_SHIFT :: 26
VERS_LOW_SHIFT :: 3

MAX_CHAN8 :: 255
MAX_CHAN16 :: 32768

Err :: enum i32 {
    NONE = 0,
    OUT_OF_MEMORY = 4,
    INTERNAL_STRUCT_DAMAGED = 512,
    INVALID_INDEX,
    UNRECOGNIZED_PARAM_TYPE,
    INVALID_CALLBACK,
    BAD_CALLBACK_PARAM,
    INTERRUPT_CANCEL,
    CANNOT_PARSE_KEYFRAME_TEXT,
}

A_Err :: enum i32 {
    NONE = 0,
    GENERIC,
    STRUCT,
    PARAMETER,
    ALLOC,
    WRONG_THREAD,
    CONST_PROJECT_MODIFICATION,
    RESERVED_7,
    RESERVED_8,
    RESERVED_9,
    RESERVED_10,
    RESERVED_11,
    RESERVED_12,
    MISSING_SUITE = 13,
    RESERVED_14,
    RESERVED_15,
    RESERVED_16,
    RESERVED_17,
    RESERVED_18,
    RESERVED_19,
    RESERVED_20,
    RESERVED_21,
    NOT_IN_CACHE_OR_COMPUTE_PENDING,
    PROJECT_LOAD_FATAL,
    EFFECT_APPLY_FATAL,
}

Cmd :: enum i32 {
    ABOUT = 0,
    GLOBAL_SETUP,
    UNUSED_0,
    GLOBAL_SETDOWN,
    PARAMS_SETUP,
    SEQUENCE_SETUP,
    SEQUENCE_RESETUP,
    SEQUENCE_FLATTEN,
    SEQUENCE_SETDOWN,
    DO_DIALOG,
    FRAME_SETUP,
    RENDER,
    FRAME_SETDOWN,
    USER_CHANGED_PARAM,
    UPDATE_PARAMS_UI,
    EVENT,
    GET_EXTERNAL_DEPENDENCIES,
    COMPLETELY_GENERAL,
    QUERY_DYNAMIC_FLAGS,
    AUDIO_RENDER,
    AUDIO_SETUP,
    AUDIO_SETDOWN,
    ARBITRARY_CALLBACK,
    SMART_PRE_RENDER,
    SMART_RENDER,
    RESERVED1,
    RESERVED2,
    RESERVED3,
    GET_FLATTENED_SEQUENCE_DATA,
    TRANSLATE_PARAMS_TO_PREFS,
    RESERVED4,
    SMART_RENDER_GPU,
    GPU_DEVICE_SETUP,
    GPU_DEVICE_SETDOWN,
}

In_Data :: struct #align (8) {
    inter:                      Interact_Callbacks,
    utils:                      ^Util_Callbacks,
    effect_ref:                 ^Progress_Info,
    quality:                    Quality,
    version:                    Spec_Version,
    serial_num:                 i32,
    appl_id:                    i32,
    num_params:                 i32,
    reserved:                   i32,
    what_cpu:                   i32,
    what_fpu:                   i32,
    current_time:               i32,
    time_step:                  i32,
    total_time:                 i32,
    local_time_step:            i32,
    time_scale:                 u32,
    field:                      Field,
    shutter_angle:              Fixed,
    width:                      i32,
    height:                     i32,
    extent_hint:                Rect,
    output_origin_x:            i32,
    output_origin_y:            i32,
    downsample_x:               Rational_Scale,
    downsample_y:               Rational_Scale,
    pixel_aspect_ratio:         Rational_Scale,
    in_flags:                   In_Flags,
    global_data:                Handle,
    sequence_data:              Handle,
    frame_data:                 Handle,
    start_sampL:                i32,
    dur_sampL:                  i32,
    total_sampL:                i32,
    src_snd:                    Sound_World,
    pica_basicP:                ^SP_Basic_Suite,
    pre_effect_source_origin_x: i32,
    pre_effect_source_origin_y: i32,
    shutter_phase:              Fixed,
}
#assert(size_of(In_Data) == 408)

Out_Data :: struct #align (8) {
    my_version:      u32,
    name:            [MAX_EFFECT_NAME_LEN + 1]byte,
    global_data:     Handle,
    num_params:      i32,
    sequence_data:   Handle,
    flat_sdata_size: i32,
    frame_data:      Handle,
    width:           i32,
    height:          i32,
    origin:          Point,
    out_flags:       Out_Flags,
    return_msg:      [MAX_EFFECT_MSG_LEN + 1]byte,
    start_sampL:     i32,
    dur_sampL:       i32,
    dest_snd:        Sound_World,
    out_flags2:      Out_Flags2,
}
#assert(size_of(Out_Data) == 408)

Param_Def :: struct #align (8) {
    uu:         struct #raw_union {
        id:           i32,
        change_flags: Change_Flags,
    },
    ui_flags:   Param_UI_Flags,
    ui_width:   i16,
    ui_height:  i16,
    param_type: Param_Type,
    name:       [MAX_EFFECT_PARAM_NAME_LEN + 1]byte,
    flags:      Param_Flags,
    unused:     i32,
    u:          Param_Def_Union,
}
#assert(size_of(Param_Def) == 176)

Interact_Callbacks :: struct #align (8) {
    checkout_param: proc "c" (
        effect_ref: ^Progress_Info,
        index: i32,
        what_time: i32,
        time_step: i32,
        time_scale: u32,
        param: ^Param_Def,
    ) -> Err,
    checkin_param:        rawptr,
    add_param:            proc "c" (
        effect_ref: ^Progress_Info,
        index: i32,
        param: ^Param_Def,
    ) -> Err,
    abort:                rawptr,
    progress:             rawptr,
    register_ui:          rawptr,
    checkout_layer_audio: rawptr,
    checkin_layer_audio:  rawptr,
    get_audio_data:       rawptr,
    reserved_str:         [3]rawptr,
    reserved:             [10]rawptr,
}
#assert(size_of(Interact_Callbacks) == 176)

Util_Callbacks :: struct #align (8) {
    begin_sampling:                proc "c" (
        effect_ref: ^Progress_Info,
        quality: Quality,
        mf: Mode_Flags,
        params: ^Samp_PB,
    ) -> Err,
    subpixel_sample:               proc "c" (
        effect_ref: ^Progress_Info,
        x, y: i32,
        params: ^Samp_PB,
        dst_pixel: ^Pixel,
    ) -> Err,
    area_sample:                   proc "c" (
        effect_ref: ^Progress_Info,
        x, y: i32,
        params: ^Samp_PB,
        dst_pixel: ^Pixel,
    ) -> Err,
    get_batch_func_is_deprecated:  rawptr,
    end_sampling:                  proc "c" (
        effect_ref: ^Progress_Info,
        quality: Quality,
        mf: Mode_Flags,
        params: ^Samp_PB,
    ) -> Err,
    composite_rect:                proc "c" (
        effect_ref: ^Progress_Info,
        src_rect: ^Rect,
        src_opacity: i32,
        source_wld: ^Effect_World,
        dest_x, dest_y: i32,
        field_rdr: Field,
        xfer_mode: i32,
        dest_wld: ^Effect_World,
    ) -> Err,
    blend:                         proc "c" (
        effect_ref: ^Progress_Info,
        src1, src2: ^Effect_World,
        ratio: i32,
        dst: ^Effect_World,
    ) -> Err,
    convolve:                      proc "c" (
        effect_ref: ^Progress_Info,
        src: ^Effect_World,
        area: ^Rect,
        flags: Kernel_Flags,
        kernel_size: i32,
        a_kernel, r_kernel, g_kernel, b_kernel: rawptr,
        dst: ^Effect_World,
    ) -> Err,
    copy:                          proc "c" (
        effect_ref: ^Progress_Info,
        src, dst: ^Effect_World,
        src_r, dst_r: ^Rect,
    ) -> Err,
    fill:                          proc "c" (
        effect_ref: ^Progress_Info,
        color: ^Pixel,
        dst_rect: ^Rect,
        world: ^Effect_World,
    ) -> Err,
    gaussian_kernel:               proc "c" (
        effect_ref: ^Progress_Info,
        k_radius: f64,
        flags: Kernel_Flags,
        multiplier: f64,
        diameter: ^i32,
        kernel: rawptr,
    ) -> Err,
    iterate:                       proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        refcon: rawptr,
        pix_fn: Iterate_Pixel8_Func,
        dst: ^Effect_World,
    ) -> Err,
    premultiply:                   proc "c" (
        effect_ref: ^Progress_Info,
        forward: i32,
        dst: ^Effect_World,
    ) -> Err,
    premultiply_color:             proc "c" (
        effect_ref: ^Progress_Info,
        src: ^Effect_World,
        color: ^Pixel,
        forward: i32,
        dst: ^Effect_World,
    ) -> Err,
    new_world:                     proc "c" (
        effect_ref: ^Progress_Info,
        width, height: i32,
        flags: New_World_Flags,
        world: ^Effect_World,
    ) -> Err,
    dispose_world:                 proc "c" (
        effect_ref: ^Progress_Info,
        world: ^Effect_World,
    ) -> Err,
    iterate_origin:                proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        origin: ^Point,
        refcon: rawptr,
        pix_fn: Iterate_Pixel8_Func,
        dst: ^Effect_World,
    ) -> Err,
    iterate_lut:                   proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        a_lut0, r_lut0, g_lut0, b_lut0: ^byte,
        dst: ^Effect_World,
    ) -> Err,
    transfer_rect:                 proc "c" (
        effect_ref: ^Progress_Info,
        quality: Quality,
        m_flags: Mode_Flags,
        field: Field,
        src_rec: ^Rect,
        src_world: ^Effect_World,
        comp_mode: ^Composite_Mode,
        mask_world0: ^Mask_World,
        dest_x, dest_y: i32,
        dst_world: ^Effect_World,
    ) -> Err,
    transform_world:               proc "c" (
        effect_ref: ^Progress_Info,
        quality: Quality,
        m_flags: Mode_Flags,
        field: Field,
        src_world: ^Effect_World,
        comp_mode: ^Composite_Mode,
        mask_world0: ^Mask_World,
        matrices: [^]matrix[3, 3]f64,
        num_matrices: i32,
        src2dst_matrix: b8,
        dest_rect: ^Rect,
        dst_world: ^Effect_World,
    ) -> Err,
    host_new_handle:               proc "c" (size: u64) -> Handle,
    host_lock_handle:              proc "c" (pf_handle: Handle) -> rawptr,
    host_unlock_handle:            proc "c" (pf_handle: Handle),
    host_dispose_handle:           proc "c" (pf_handle: Handle),
    get_callback_addr:             proc "c" (
        effect_ref: ^Progress_Info,
        quality: Quality,
        mode_flags: Mode_Flags,
        which_callback: Callback_ID,
        fn: Callback_Func,
    ) -> Err,
    app:                           rawptr, // IDK
    ansi:                          ANSI_Callbacks,
    color_cb:                      Color_Callbacks,
    get_platform_data:             proc "c" (
        effect_ref: ^Progress_Info,
        which: Plat_Data_ID,
        data: rawptr,
    ) -> Err,
    host_get_handle_size:          proc "c" (pf_handle: Handle) -> u64,
    iterate_origin_non_clip_src:   proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        origin: ^Point,
        refcon: rawptr,
        pix_fn: Iterate_Pixel8_Func,
        dst: ^Effect_World,
    ) -> Err,
    iterate_generic:               proc "c" (
        iterationsL: i32,
        refcon_pv: rawptr,
        fn: proc "c" (refcon_pv: rawptr, thread_indexL, i, iterationsL: i32) -> Err,
    ) -> Err,
    host_resize_handle:            proc "c" (new_sizeL: u64, handle_PH: Handle) -> Err,
    subpixel_sample16:             proc "c" (
        effect_ref: ^Progress_Info,
        x, y: i32,
        params: ^Samp_PB,
        dst_pixel: ^Pixel16,
    ) -> Err,
    area_sample16:                 proc "c" (
        effect_ref: ^Progress_Info,
        x, y: i32,
        params: ^Samp_PB,
        dst_pixel: ^Pixel16,
    ) -> Err,
    fill16:                        proc "c" (
        effect_ref: ^Progress_Info,
        color: ^Pixel16,
        dst_rect: ^Rect,
        world: ^Effect_World,
    ) -> Err,
    premultiply_color16:           proc "c" (
        effect_ref: ^Progress_Info,
        src: ^Effect_World,
        color: ^Pixel16,
        forward: i32,
        dst: ^Effect_World,
    ) -> Err,
    iterate16:                     proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        refcon: rawptr,
        pix_fn: Iterate_Pixel16_Func,
        dst: ^Effect_World,
    ) -> Err,
    iterate_origin16:              proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        origin: ^Point,
        refcon: rawptr,
        pix_fn: Iterate_Pixel16_Func,
        dst: ^Effect_World,
    ) -> Err,
    iterate_origin_non_clip_src16: proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        origin: ^Point,
        refcon: rawptr,
        pix_fn: Iterate_Pixel16_Func,
        dst: ^Effect_World,
    ) -> Err,
    get_pixel_data8:               proc "c" (
        world: ^Effect_World,
        pixels: ^Pixel,
        pix: ^^Pixel,
    ) -> Err,
    get_pixel_data16:              proc "c" (
        world: ^Effect_World,
        pixels: ^Pixel,
        pix: ^^Pixel16,
    ) -> Err,
    reserved:                      [1]i32,
}
#assert(size_of(Util_Callbacks) == 552)

Progress_Info :: struct {}

Quality :: enum i32 {
    DRAWING_AUDIO = -1,
    LO = 0,
    HI,
}

Spec_Version :: struct #align (2) {
    major: i16,
    minor: i16,
}

Field :: enum i32 {
    FRAME = 0,
    UPPER = 1,
    LOWER = 2,
}

Fixed :: distinct i32

fix_to_i32 :: proc "contextless" (x: Fixed) -> i32 {
    return i32(x) >> 16
}

i32_to_fix :: proc "contextless" (x: i32) -> Fixed {
    return Fixed(x << 16)
}

fix_to_i32_round :: proc "contextless" (x: Fixed) -> i32 {
    return fix_to_i32(x + 32768)
}

fix_to_f64 :: proc "contextless" (x: Fixed) -> f64 {
    return f64(x) / 65536
}

f64_to_fix :: proc "contextless" (x: f64) -> Fixed {
    return Fixed(x * 65536 + ((x < 0) ? -0.5 : 0.5))
}

Rect :: struct #align (4) {
    left:   i32,
    top:    i32,
    right:  i32,
    bottom: i32,
}

Rational_Scale :: struct #align (4) {
    num: i32,
    den: u32,
}

In_Flags :: enum i32 {
    NONE                   = 0,
    PROJECT_IS_RENDER_ONLY = 1,
}

Handle :: ^rawptr

Sound_World :: struct #align (8) {
    fi:          Sound_Format_Info,
    num_samples: i32,
    dataP:       rawptr,
}

Sound_Format_Info :: struct #align (8) {
    rateF:        f64,
    num_channels: i16,
    format:       i16,
    sample_size:  i16,
}

SP_Err :: distinct i32

SP_Basic_Suite :: struct #align (8) {
    acquire_suite:    proc "c" (name: cstring, version: i32, suite: ^rawptr) -> SP_Err,
    release_suite:    proc "c" (name: cstring, version: i32) -> SP_Err,
    is_equal:         proc "c" (token1, token2: cstring) -> SP_Err,
    allocate_block:   proc "c" (size: uint, block: ^rawptr) -> SP_Err,
    free_block:       proc "c" (block: rawptr) -> SP_Err,
    reallocate_block: proc "c" (block: rawptr, new_size: uint, new_block: ^rawptr) -> SP_Err,
    undefined:        proc "c" () -> SP_Err,
}
#assert(size_of(SP_Basic_Suite) == 56)

Point :: struct #align (4) {
    x: i32,
    y: i32,
}

Samp_PB :: struct #align (8) {
    x_radius:     i32,
    y_radius:     i32,
    area:         i32,
    src:          ^Effect_World,
    samp_behave:  Sample_Edge_Behav,
    allow_asynch: i32,
    motion_blur:  i32,
    comp_mode:    Composite_Mode,
    mask0:        ^Pixel,
    fcm_table:    ^byte,
    fcd_table:    ^byte,
    reserved:     [8]i32,
}
#assert(size_of(Samp_PB) == 104)

Composite_Mode :: struct #align (4) {
    xfer:       i32,
    rand_seed:  i32,
    opacity:    u8,
    rgb_only:   b8,
    opacity_su: u16,
}
#assert(size_of(Composite_Mode) == 12)

Iterate_Pixel8_Func :: proc "c" (refcon: rawptr, xL, yL: i32, inP: ^Pixel, outP: ^Pixel) -> Err
Iterate_Pixel16_Func :: proc "c" (
    refcon: rawptr,
    xL, yL: i32,
    inP: ^Pixel16,
    outP: ^Pixel16,
) -> Err
Iterate_PixelFloat_Func :: proc "c" (
    refcon: rawptr,
    xL, yL: i32,
    inP: ^Pixel32,
    outP: ^Pixel32,
) -> Err

Sample_Edge_Behav :: enum u32 {
    ZERO = 0,
}

New_World_Flag :: enum {
    CLEAR_PIXELS,
    DEEP_PIXELS,
}
New_World_Flags :: bit_set[New_World_Flag;i32]

Mode_Flag :: enum {
    ALPHA_STRAIGHT,
}
Mode_Flags :: bit_set[Mode_Flag;i32] // empty == ALPHA_PREMUL

Kernel_Flag :: enum {
    _1D,
    NORMALIZED,
    NO_CLAMP,
    USE_CHAR,
    USE_FIXED,
    VERTICAL,
    REPLICATE_BORDERS,
    ALPHA_WEIGHT_CONVOLVE,
}
Kernel_Flags :: bit_set[Kernel_Flag;u32]

Callback_ID :: enum i32 {
    NONE = 0,
    BEGIN_SAMPLING,
    SUBPIXEL_SAMPLE,
    AREA_SAMPLE,
    OBSOLETE0,
    END_SAMPLING,
    COMPOSITE_RECT,
    BLEND,
    CONVOLVE,
    COPY,
    FILL,
    GAUSSIAN,
    ITERATE,
    PREMUL,
    PREMUL_COLOR,
    RGB_TO_HLS,
    HLS_TO_RGB,
    RGB_TO_YIQ,
    YIQ_TO_RGB,
    LUMINANCE,
    HUE,
    LIGHTNESS,
    SATURATION,
    NEW_WORLD,
    DISPOSE_WORLD,
    ITERATE_ORIGIN,
    ITERATE_LUT,
    TRANSFER_RECT,
    TRANSFORM_WORLD,
    ITERATE_ORIGIN_NON_CLIP_SRC,
    ITERATE_GENERIC,
    SUBPIXEL_SAMPLE16,
    AREA_SAMPLE16,
    FILL16,
    PREMUL_COLOR16,
    ITERATE16,
    ITERATE_ORIGIN16,
    ITERATE_ORIGIN_NON_CLIP_SRC16,
    ITERATE_GENERIC_NO_MAX_THREADS,
    ITERATE_NO_MAX_THREADS,
    ITERATE_ORIGIN_NON_CLIP_SRC_NO_MAX_THREADS,
    ITERATE16_NO_MAX_THREADS,
    ITERATE_ORIGIN16_NO_MAX_THREADS,
    ITERATE_ORIGIN_NON_CLIP_SRC16_NO_MAX_THREADS,
}

Callback_Func :: rawptr

ANSI_Callbacks :: struct #align (8) {
    padding: [160]byte,
}
#assert(size_of(ANSI_Callbacks) == 160)

Color_Callbacks :: struct #align (8) {
    rgb_to_hls: proc "c" (effect_ref: ^Progress_Info, rgb: ^Pixel, hls: HLS_Pixel) -> Err,
    hls_to_rgb: proc "c" (effect_ref: ^Progress_Info, hls: HLS_Pixel, rgb: ^Pixel) -> Err,
    rgb_to_yiq: proc "c" (effect_ref: ^Progress_Info, rgb: ^Pixel, yiq: YIQ_Pixel) -> Err,
    yiq_to_rgb: proc "c" (effect_ref: ^Progress_Info, yiq: YIQ_Pixel, rgb: ^Pixel) -> Err,
    luminance:  proc "c" (effect_ref: ^Progress_Info, rgb: ^Pixel, lum100: ^i32) -> Err,
    hue:        proc "c" (effect_ref: ^Progress_Info, rgb: ^Pixel, hue: ^i32) -> Err,
    lightness:  proc "c" (effect_ref: ^Progress_Info, rgb: ^Pixel, lightness: ^i32) -> Err,
    saturation: proc "c" (effect_ref: ^Progress_Info, rgb: ^Pixel, saturation: ^i32) -> Err,
}
#assert(size_of(Color_Callbacks) == 64)

HLS_Pixel :: ^[3]i32
YIQ_Pixel :: ^[3]i32

Plat_Data_ID :: enum i32 {
    MAIN_WND = 0,
    EXE_FILE_PATH_DEPRECATED,
    RES_FILE_PATH_DEPRECATED,
    RES_REFNUM,
    RES_DLLINSTANCE,
    SP_PLUG_REF,
    BUNDLE_REF,
    EXE_FILE_PATH_W,
    RES_FILE_PATH_W,
}

Out_Flag :: enum {
    KEEP_RESOURCE_OPEN,
    WIDE_TIME_INPUT,
    NON_PARAM_VARY,
    RESERVED6,
    SEQUENCE_DATA_NEEDS_FLATTENING,
    I_DO_DIALOG,
    USE_OUTPUT_EXTENT,
    SEND_DO_DIALOG,
    DISPLAY_ERROR_MESSAGE,
    I_EXPAND_BUFFER,
    PIX_INDEPENDENT,
    I_WRITE_INPUT_BUFFR,
    I_SHRINK_BUFFER,
    WORKS_IN_PLACE,
    RESERVED8,
    CUSTOM_UI,
    RESERVED7,
    REFRESH_UI,
    NOP_RENDER,
    I_USE_SHUTTER_ANGLE,
    I_USE_AUDIO,
    I_AM_OBSOLETE,
    FORCE_RERENDER,
    PiPL_OVERRIDES_OUTDATA_OUTFLAGS,
    I_HAVE_EXTERNAL_DEPENDENCIES,
    DEEP_COLOR_AWARE,
    SEND_UPDATE_PARAMS_UI,
    AUDIO_FLOAT_ONLY,
    AUDIO_IIR,
    I_SYNTHESIZE_AUDIO,
    AUDIO_EFFECT_TOO,
    AUDIO_EFFECT_ONLY,
}
Out_Flags :: bit_set[Out_Flag;i32]

Out_Flag2 :: enum {
    SUPPORTS_QUERY_DYNAMIC_FLAGS,
    I_USE_3D_CAMERA,
    I_USE_3D_LIGHTS,
    PARAM_GROUP_START_COLLAPSED_FLAG,
    I_AM_THREADSAFE,
    CAN_COMBINE_WITH_DESTINATION,
    DOESNT_NEED_EMPTY_PIXELS,
    REVEALS_ZERO_ALPHA,
    PRESERVES_FULLY_OPAQUE_PIXELS,
    UNUSED,
    SUPPORTS_SMART_RENDER,
    RESERVED9,
    FLOAT_COLOR_AWARE,
    I_USE_COLORSPACE_ENUMERATION,
    I_AM_DEPRECATED,
    PPRO_DO_NOT_CLONE_SEQUENCE_DATA_FOR_RENDER,
    RESERVED10,
    AUTOMATIC_WIDE_TIME_INPUT,
    I_USE_TIMECODE,
    DEPENDS_ON_UNREFERENCED_MASKS,
    OUTPUT_IS_WATERMARKED,
    I_MIX_GUID_DEPENDENCIES,
    AE13_5_THREADSAFE,
    SUPPORTS_GET_FLATTENED_SEQUENCE_DATA,
    CUSTOM_UI_ASYNC_MANAGER,
    SUPPORTS_GPU_RENDER_F32,
    RESERVED12,
    SUPPORTS_THREADED_RENDERING,
    MUTABLE_RENDER_SEQUENCE_DATA_SLOWER,
    SUPPORTS_DIRECTX_RENDERING,
}
Out_Flags2 :: bit_set[Out_Flag2;i32]

Change_Flag :: enum {
    CHANGED_VALUE,
    RESERVED,
    SET_TO_VARY,
    SET_TO_CONSTANT,
}
Change_Flags :: bit_set[Change_Flag;i32]

Param_UI_Flag :: enum {
    TOPIC,
    CONTROL,
    STD_CONTROL_ONLY,
    NO_ECW_UI,
    ECW_SEPARATOR,
    DISABLED,
    DONT_ERASE_TOPIC,
    DONT_ERASE_CONTROL,
    RADIO_BUTTON,
    INVISIBLE,
}
Param_UI_Flags :: bit_set[Param_UI_Flag;i32]

Param_Type :: enum i32 {
    RESERVED = -1,
    LAYER = 0,
    SLIDER,
    FIX_SLIDER,
    ANGLE,
    CHECKBOX,
    COLOR,
    POINT,
    POPUP,
    CUSTOM,
    NO_DATA,
    FLOAT_SLIDER,
    ARBITRARY_DATA,
    PATH,
    GROUP_START,
    GROUP_END,
    BUTTON,
    RESERVED2,
    RESERVED3,
    POINT_3D,
}

Param_Flag :: enum {
    RESERVED1,
    CANNOT_TIME_VARY,
    CANNOT_INTERP,
    RESERVED2,
    RESERVED3,
    COLLAPSE_TWIRLY,
    // START_COLLAPSED = COLLAPSE_TWIRLY, (does this work?)
    SUPERVISE,
    USE_VALUE_FOR_OLD_PROJECTS,
    LAYER_PARAM_IS_TRACKMATTE,
    EXCLUDE_FROM_HAVE_INPUTS_CHANGED,
    SKIP_REVEAL_WHEN_UNHIDDEN,
}
Param_Flags :: bit_set[Param_Flag;i32]

Param_Def_Union :: struct #raw_union #align (8) {
    ld:        Layer_Def,
    sd:        Slider_Def,
    fd:        Fixed_Slider_Def,
    ad:        Angle_Def,
    bd:        Checkbox_Def,
    cd:        Color_Def,
    td:        Point_Def,
    pd:        Popup_Def,
    fs_d:      Float_Slider_Def,
    arb_d:     Arbitrary_Def,
    path_d:    Path_Def,
    button_d:  Button_Def,
    point3d_d: Point3D_Def,
}
#assert(size_of(Param_Def_Union) == 120)

Layer_Def :: struct #align (8) {
    reserved0:                rawptr,
    reserved1:                rawptr,
    world_flags:              World_Flags,
    data:                     ^Pixel_Opaque,
    rowbytes:                 i32,
    width:                    i32,
    height:                   i32,
    extent_hint:              Rect,
    platform_ref:             rawptr,
    reserved_long1:           i32,
    reserved_long4:           rawptr,
    pix_aspect_ratio:         Rational_Scale,
    reserved_long2, origin_x: i32,
    origin_y:                 i32,
    reserved_long3:           i32,
    dephault:                 i32,
}
#assert(size_of(Layer_Def) == 120)

Effect_World :: Layer_Def

Slider_Def :: struct #align (4) {
    value:      i32,
    value_str:  [MAX_PARAM_VALUE_LEN + 1]byte,
    value_desc: [MAX_PARAM_DESCRIPTION_LEN + 1]byte,
    valid_min:  i32,
    valid_max:  i32,
    slider_min: i32,
    slider_max: i32,
    dephault:   i32,
}
#assert(size_of(Slider_Def) == 88)

Fixed_Slider_Def :: struct #align (4) {
    value:         i32,
    value_str:     [MAX_PARAM_VALUE_LEN + 1]byte,
    value_desc:    [MAX_PARAM_DESCRIPTION_LEN + 1]byte,
    valid_min:     i32,
    valid_max:     i32,
    slider_min:    i32,
    slider_max:    i32,
    dephault:      i32,
    precision:     i16,
    display_flags: Value_Display_Flags,
}
#assert(size_of(Fixed_Slider_Def) == 92)

Angle_Def :: struct #align (4) {
    value:     i32,
    dephault:  i32,
    valid_min: i32,
    valid_max: i32,
}

Checkbox_Def :: struct #align (8) {
    value:     i32,
    dephault:  b8,
    reserved:  byte,
    reserved1: i16,
    name:      cstring,
}

Color_Def :: struct #align (1) {
    value:    Pixel,
    dephault: Pixel,
}

Point_Def :: struct #align (4) {
    x_value:         i32,
    y_value:         i32,
    reserved:        [3]byte,
    restrict_bounds: b8,
    x_dephault:      i32,
    y_dephault:      i32,
}
#assert(size_of(Point_Def) == 20)

Popup_Def :: struct #align (8) {
    value:       i32,
    num_choices: i16,
    dephault:    i16,
    names:       cstring,
}
#assert(size_of(Popup_Def) == 16)

Float_Slider_Def :: struct #align (8) {
    value:           f64,
    phase:           f64,
    value_desc:      [MAX_PARAM_DESCRIPTION_LEN + 1]byte,
    valid_min:       f32,
    valid_max:       f32,
    slider_min:      f32,
    slider_max:      f32,
    dephault:        f32,
    precision:       i16,
    display_flags:   Value_Display_Flags,
    fs_flags:        FSlider_Flags,
    curve_tolerance: f32,
    use_exponent:    b8,
    exponent:        f32,
}
#assert(size_of(Float_Slider_Def) == 88)

Arbitrary_Def :: struct #align (8) {
    id:        i16,
    pad:       i16,
    dephault:  Handle,
    value:     Handle,
    refcon_pv: rawptr,
}
#assert(size_of(Arbitrary_Def) == 32)

Path_Def :: struct #align (4) {
    path_id:   Path_ID,
    reserved0: i32,
    dephault:  i32,
}

Button_Def :: struct #align (8) {
    value: i32,
    names: cstring,
}

Point3D_Def :: struct #align (8) {
    x_value:    f64,
    y_value:    f64,
    z_value:    f64,
    x_dephault: f64,
    y_dephault: f64,
    z_dephault: f64,
    reserved:   [16]byte,
}
#assert(size_of(Point3D_Def) == 64)

World_Flag :: enum {
    DEEP,
    WRITEABLE,
}
World_Flags :: bit_set[World_Flag;i32]

Pixel_Opaque :: struct {}

Value_Display_Flag :: enum {
    PERCENT,
    PIXEL,
    RESERVED1,
    REVERSE,
}
Value_Display_Flags :: bit_set[Value_Display_Flag;i16]

Pixel :: struct #align (1) {
    alpha: u8,
    red:   u8,
    green: u8,
    blue:  u8,
}

Pixel16 :: struct #align (2) {
    alpha: u16,
    red:   u16,
    green: u16,
    blue:  u16,
}

Pixel32 :: struct #align (4) {
    alpha: f32,
    red:   f32,
    green: f32,
    blue:  f32,
}

Mask_World :: struct #align (8) {
    mask:         Effect_World,
    offset:       Point,
    what_is_mask: Mask_Flags,
}
#assert(size_of(Mask_World) == 136)

Mask_Flag :: enum {
    INVERTED,
    LUMINANCE,
}
Mask_Flags :: bit_set[Mask_Flag;i32]

FSlider_Flag :: enum {
    WANT_PHASE,
}
FSlider_Flags :: bit_set[FSlider_Flag;u32]

Path_ID :: distinct i32

make_pixel_format_fourcc :: proc "contextless" (ch0, ch1, ch2, ch3: u8) -> u32 {
    return (u32(ch0) << 0) | (u32(ch1) << 8) | (u32(ch2) << 16) | (u32(ch3) << 24)
}

Pixel_Format :: enum i32 {
    ARGB32      = 1650946657,
    ARGB64      = 909206881,
    ARGB128     = 842229089,
    GPU_BGRA128 = 1094992704,
    RESERVED    = 1631863616,
    BGRA32      = 1634887522,
    VUYA32      = 1635349878,
    NTCSDV25    = 846100068,
    PALDV25     = 846231140,
    INVALID     = 1717854562,
}

Plugin_Data :: struct {}

Pre_Render_Extra :: struct #align (8) {
    input:  ^Pre_Render_Input,
    output: ^Pre_Render_Output,
    cb:     ^Pre_Render_Callbacks,
}

Smart_Render_Input :: struct #align (8) {
    output_request:  Render_Request,
    bit_depth:       i16,
    pre_render_data: rawptr,
    gpu_data:        rawptr,
    what_gpu:        GPU_Framework,
    device_index:    u32,
}
#assert(size_of(Smart_Render_Input) == 72)

Smart_Render_Callbacks :: struct #align (8) {
    checkout_layer_pixels: proc "c" (
        effect_ref: ^Progress_Info,
        checkout_id: i32,
        pixels: ^^Effect_World,
    ) -> Err,
    checkin_layer_pixels: proc "c" (
        effect_ref: ^Progress_Info,
        checkout_id: i32,
    ) -> Err,
    checkout_output: proc "c" (
        effect_ref: ^Progress_Info,
        output: ^^Effect_World,
    ) -> Err,
}

Smart_Render_Extra :: struct #align (8) {
    input: ^Smart_Render_Input,
    cb: ^Smart_Render_Callbacks,
}

GPU_Device_Setup_Input :: struct #align (4) {
    what_gpu: GPU_Framework,
    device_index: u32,
}
#assert(size_of(GPU_Device_Setup_Input) == 8)

GPU_Device_Setup_Output :: struct #align (8) {
    gpu_data: rawptr,
}

GPU_Device_Setup_Extra :: struct #align (8) {
    input: ^GPU_Device_Setup_Input,
    output: ^GPU_Device_Setup_Output,
}

GPU_Device_Setdown_Input :: struct #align (8) {
    gpu_data: rawptr,
    what_gpu: GPU_Framework,
    device_index: u32,
}
#assert(size_of(GPU_Device_Setdown_Input) == 16)

GPU_Device_Setdown_Extra :: struct #align (8) {
    input: ^GPU_Device_Setdown_Input,
}

Pre_Render_Input :: struct #align (8) {
    output_request: Render_Request,
    bit_depth:      i16,
    gpu_data:       rawptr,
    what_gpu:       GPU_Framework,
    device_index:   u32,
}
#assert(size_of(Pre_Render_Input) == 64)

Render_Request :: struct #align (4) {
    rect:                       Rect,
    field:                      Field,
    channel_mask:               Channel_Mask,
    preserve_rgb_of_zero_alpha: b8,
    unused:                     [3]byte,
    reserved:                   [4]i32,
}
#assert(size_of(Render_Request) == 44)

GPU_Device_Info :: struct #align (8) {
    device_framework: GPU_Framework,
    compatible: b8,
    platform_pv: rawptr,
    device_pv: rawptr,
    context_pv: rawptr,
    command_queue_pv: rawptr,
    offscreen_opengl_context_pv: rawptr,
    offscreen_opengl_device_pv: rawptr,
}
#assert(size_of(GPU_Device_Info) == 56)

Pre_Render_Output :: struct #align (8) {
    result_rect:                 Rect,
    max_result_rect:             Rect,
    solid:                       b8,
    reserved:                    b8,
    flags:                       Render_Output_Flags,
    pre_render_data:             rawptr,
    delete_pre_render_data_func: proc "c" (pre_render_data: rawptr),
}
#assert(size_of(Pre_Render_Output) == 56)

Pre_Render_Callbacks :: struct #align (8) {
    checkout_layer:  proc(
        effect_ref: ^Progress_Info,
        index: i32,
        checkout_id: i32,
        req: ^Render_Request,
        what_time: i32,
        time_step: i32,
        time_scale: u32,
        checkout_result: ^Checkout_Result,
    ) -> Err,
    guid_mix_in_ptr: proc(effect_ref: ^Progress_Info, buf_size: u32, buf: rawptr) -> Err,
}

Checkout_Result :: struct #align (4) {
    result_rect:     Rect,
    max_result_rect: Rect,
    par:             Rational_Scale,
    solid:           b8,
    reserved:        [3]byte,
    ref_width:       i32,
    ref_height:      i32,
    reserved2:       [6]i32,
}
#assert(size_of(Checkout_Result) == 76)

Render_Output_Flag :: enum {
    RETURNS_EXTRA_PIXELS,
    GPU_RENDER_POSSIBLE,
    RESERVED1,
}
Render_Output_Flags :: bit_set[Render_Output_Flag;i16]

GPU_Framework :: enum i32 {
    NONE = 0,
    OPENCL,
    METAL,
    CUDA,
    DIRECTX,
}

Channel_Mask_Flag :: enum {
    ALPHA,
    RED,
    GREEN,
    BLUE,
    ARGB,
}
Channel_Mask :: bit_set[Channel_Mask_Flag;i32]

Plugin_Data_CB2 :: proc "c" (
    inptr: ^Plugin_Data,
    name, match_name, category, entry_point: cstring,
    inkind, in_api_version_major, in_api_version_minor, in_reserved_info: i32,
    support_url: cstring,
) -> A_Err

vers_high :: proc "contextless" (vers: u32) -> u32 {
    return vers >> VERS_LOW_SHIFT
}

version :: proc "contextless" (vers, subvers, bugvers, stage, build: u32) -> u32 {
    return u32(
        ((vers_high(vers) & VERS_HIGH_BITS) << VERS_HIGH_SHIFT) |
        ((vers & VERS_BITS) << VERS_SHIFT) |
        ((subvers & SUBVERS_BITS) << SUBVERS_SHIFT) |
        ((bugvers & BUGFIX_BITS) << BUGFIX_SHIFT) |
        ((stage & STAGE_BITS) << STAGE_SHIFT) |
        ((build & BUILD_BITS) << BUILD_SHIFT),
    )
}

register_effect_ext2 :: proc "contextless" (
    inptr: ^Plugin_Data,
    cb: Plugin_Data_CB2,
    name, match_name, category: cstring,
    reserved_info: i32,
    entry_point, support_url: cstring,
) -> Err {
    result := cb(
        inptr,
        name,
        match_name,
        category,
        entry_point,
        1699105620,
        AE_PLUG_IN_VERSION,
        AE_PLUG_IN_SUBVERS,
        reserved_info,
        support_url,
    )

    return Err(result)
}

world_is_deep :: proc "contextless" (w: ^Layer_Def) -> bool {
    return .DEEP in w.world_flags
}

get_pixel8 :: proc "contextless" (in_data: ^In_Data, world: ^Layer_Def, p0: ^Pixel) -> ^Pixel {
    pixel: ^Pixel
    in_data.utils.get_pixel_data8(world, nil, &pixel)
    return pixel
}

get_pixel16 :: proc "contextless" (
    in_data: ^In_Data,
    world: ^Layer_Def,
    p0: ^Pixel16,
) -> ^Pixel16 {
    pixel: ^Pixel16
    in_data.utils.get_pixel_data16(world, nil, &pixel)
    return pixel
}

is_empty_rect :: proc "contextless" (r: ^Rect) -> bool {
    return (r.left >= r.right) || (r.top >= r.bottom);
}

union_rect :: proc "contextless" (
    src: ^Rect,
    dst: ^Rect,
) {
    if is_empty_rect(dst) {
        dst^ = src^
    } else if (!is_empty_rect(src)) {
        dst.left = min(dst.left, src.left)
        dst.top = min(dst.top, src.top)
        dst.right = max(dst.right, src.right)
        dst.bottom = max(dst.bottom, src.bottom)
	}
}