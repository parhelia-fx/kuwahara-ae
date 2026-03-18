package dof

import "base:runtime"
import "core:c/libc"
import "core:fmt"
import "core:thread"
import "core:sys/windows"

import "vendor/adb"

Effect_Params :: struct {
    kernel_size: i32,
}

Effect_Params_ID :: enum {
    INPUT = 0,
    KERNEL_SIZE,
}

Effect_GPU_Data :: struct {
    src: rawptr,
    dst: rawptr,
    width: u32,
    height: u32,
    input_pitch: u32,
    output_pitch: u32,
    kernel_size: u32,
}
#assert(size_of(Effect_GPU_Data) <= 128) // need to make sure it can be sent through push constants

PLUGIN_NAME :: "Kuwahara Filter"
MATCH_NAME :: "PARHELIA_KUWAHARA_FILTER"
DESCRIPTION :: "Copyright 2026 Parhelia"
CATEGORY :: "Parhelia"
SUPPORT_URL :: ""
MAJOR_VERSION :: 1
MINOR_VERSION :: 0

default_params :: Effect_Params {
    kernel_size = 4,
}

console_pipe: ^libc.FILE
console_init :: proc() {
    windows.AllocConsole()
    console_pipe = libc.freopen("CONOUT$", "w", libc.stderr)
}

console_uninit :: proc() {
    libc.fclose(console_pipe)
}

about :: proc(
    in_data: ^adb.In_Data,
    out_data: ^adb.Out_Data,
    params: [^]^adb.Param_Def,
    output: ^adb.Layer_Def,
) -> adb.Err {
    fmt.bprintf(
        out_data.return_msg[:],
        "%s v%d.%d\r%s",
        PLUGIN_NAME,
        MAJOR_VERSION,
        MINOR_VERSION,
        DESCRIPTION,
    )
    return .NONE
}

global_setup :: proc(in_data: ^adb.In_Data, out_data: ^adb.Out_Data) -> adb.Err {
    out_data.my_version = adb.version(MAJOR_VERSION, MINOR_VERSION, 0, 0, 1)
    // out_data.out_flags = {.PIX_INDEPENDENT, .DEEP_COLOR_AWARE}
    out_data.out_flags = {.DEEP_COLOR_AWARE}
    out_data.out_flags2 = {
        .FLOAT_COLOR_AWARE,
        .SUPPORTS_SMART_RENDER,
        .SUPPORTS_THREADED_RENDERING,
        .SUPPORTS_GPU_RENDER_F32,
        .SUPPORTS_DIRECTX_RENDERING,
    }

    load_suites(in_data.pica_basicP)

    when ODIN_DEBUG {
        console_init()
    }

    return .NONE
}

global_setdown :: proc(in_data: ^adb.In_Data) -> adb.Err {
    when ODIN_DEBUG {
        console_uninit()
    }

    release_suites(in_data.pica_basicP)

    return .NONE
}

params_setup :: proc(
    in_data: ^adb.In_Data,
    out_data: ^adb.Out_Data,
    params: [^]^adb.Param_Def,
    output: ^adb.Layer_Def,
) -> adb.Err {
    def := adb.Param_Def {
        param_type = .SLIDER,
        u = {
            sd = {
                value = default_params.kernel_size,
                valid_min = 1,
                valid_max = 500,
                slider_min = 1,
                slider_max = 500,
                dephault = default_params.kernel_size,
            },
        },
        uu = {id = i32(Effect_Params_ID.KERNEL_SIZE)},
    }
    fmt.bprint(def.name[:], "kernel size")

    in_data.inter.add_param(in_data.effect_ref, -1, &def) or_return

    out_data.num_params = len(Effect_Params_ID)
    return .NONE
}

gpu_device_setup :: proc(
    in_data: ^adb.In_Data,
    out_data: ^adb.Out_Data,
    extra: ^adb.GPU_Device_Setup_Extra,
) -> adb.Err {
    out_data.out_flags2 = {.SUPPORTS_GPU_RENDER_F32}

    // TODO: Check if context has already been initialized by another plugin

    when ODIN_DEBUG {
        libc.fprintf(libc.stderr, "[DEBUG MODE]\n")

        switch extra.input.what_gpu {
            case .NONE:
                return .UNRECOGNIZED_PARAM_TYPE
            case .OPENCL:
                libc.fprintf(libc.stderr, "API: OpenCL\n")
            case .METAL:
                libc.fprintf(libc.stderr, "API: Metal\n")
            case .CUDA:
                libc.fprintf(libc.stderr, "API: CUDA\n")
            case .DIRECTX:
                libc.fprintf(libc.stderr, "API: DirectX\n")
        }
    }

    gpu_ctx = gpu_init()
    gpu_pipeline = gpu_pipeline_init(gpu_ctx, u32(size_of(Effect_GPU_Data)))

    return .NONE
}

gpu_device_setdown :: proc(
    in_data: ^adb.In_Data,
    out_data: ^adb.Out_Data,
    extra: ^adb.GPU_Device_Setdown_Extra,
) -> adb.Err {
    gpu_synchronize(gpu_ctx)
    gpu_pipeline_uninit(gpu_ctx, &gpu_pipeline)
    gpu_uninit(&gpu_ctx)
    return .NONE
}

smart_pre_render :: proc(
    in_data: ^adb.In_Data,
    out_data: ^adb.Out_Data,
    extra: ^adb.Pre_Render_Extra,
) -> adb.Err {
    extra.output.flags += {.GPU_RENDER_POSSIBLE}

    kernel_size: adb.Param_Def
    in_data.inter.checkout_param(
        in_data.effect_ref,
        i32(Effect_Params_ID.KERNEL_SIZE),
        in_data.current_time,
        in_data.time_step,
        in_data.time_scale,
        &kernel_size,
    ) or_return

    req := extra.input.output_request
    in_result: adb.Checkout_Result
    extra.cb.checkout_layer(
        in_data.effect_ref,
        i32(Effect_Params_ID.INPUT),
        i32(Effect_Params_ID.INPUT),
        &req,
        in_data.current_time,
        in_data.time_step,
        in_data.time_scale,
        &in_result
    ) or_return

    adb.union_rect(&in_result.result_rect, &extra.output.result_rect)
    adb.union_rect(&in_result.max_result_rect, &extra.output.max_result_rect)
    return .NONE
}

smart_render :: proc(
    in_data: ^adb.In_Data,
    out_data: ^adb.Out_Data,
    extra: ^adb.Smart_Render_Extra,
) -> adb.Err {
    input_world: ^adb.Effect_World
    output_world: ^adb.Effect_World

    extra.cb.checkout_layer_pixels(
        in_data.effect_ref,
        i32(Effect_Params_ID.INPUT),
        &input_world
    ) or_return
    src_img: rawptr
    suites.gpu_device_suite1.get_gpu_world_data(in_data.effect_ref, input_world, &src_img) or_return

    extra.cb.checkout_output(
        in_data.effect_ref,
        &output_world
    ) or_return
    dst_img: rawptr
    suites.gpu_device_suite1.get_gpu_world_data(in_data.effect_ref, output_world, &dst_img) or_return

    params: Effect_Params

    temp_param: adb.Param_Def
    in_data.inter.checkout_param(
        in_data.effect_ref,
        i32(Effect_Params_ID.KERNEL_SIZE),
        in_data.current_time,
        in_data.time_step,
        in_data.time_scale,
        &temp_param
    ) or_return
    params.kernel_size = temp_param.u.sd.value


    // Prepare GPU Data
    gpu_data := Effect_GPU_Data {
        src = src_img,
        dst = dst_img,
        width = u32(input_world.width),
        height = u32(input_world.height),
        input_pitch = u32(input_world.rowbytes / 16),
        output_pitch = u32(output_world.rowbytes / 16),
        kernel_size = u32(params.kernel_size),
    }
    effect_render(&gpu_ctx, gpu_pipeline, gpu_data)

    extra.cb.checkin_layer_pixels(
        in_data.effect_ref,
        i32(Effect_Params_ID.INPUT)
    ) or_return

    return .NONE
}

@(export = true, link_name = "PluginDataEntryFunction2")
plugin_data_entry_function2 :: proc "c" (
    inptr: ^adb.Plugin_Data,
    in_plugin_data_cb: adb.Plugin_Data_CB2,
    in_sp_basic_suite: ^adb.SP_Basic_Suite,
    in_host_name, in_host_version: cstring,
) -> adb.Err {
    return adb.register_effect_ext2(
        inptr,
        in_plugin_data_cb,
        PLUGIN_NAME,
        MATCH_NAME,
        CATEGORY,
        8,
        "EffectMain",
        SUPPORT_URL,
    )
}

@(export = true, link_name = "EffectMain")
effect_main :: proc "c" (
    cmd: adb.Cmd,
    in_data: ^adb.In_Data,
    out_data: ^adb.Out_Data,
    params: [^]^adb.Param_Def,
    output: ^adb.Layer_Def,
    extra: rawptr,
) -> adb.Err {
    context = runtime.default_context()

    err := adb.Err.NONE

    #partial switch (cmd) {
    case .ABOUT:
        err = about(in_data, out_data, params, output)
    case .GLOBAL_SETUP:
        err = global_setup(in_data, out_data)
    case .GLOBAL_SETDOWN:
        err = global_setdown(in_data)
    case .PARAMS_SETUP:
        err = params_setup(in_data, out_data, params, output)
    case .GPU_DEVICE_SETUP:
        err = gpu_device_setup(in_data, out_data, (^adb.GPU_Device_Setup_Extra)(extra))
    case .GPU_DEVICE_SETDOWN:
        err = gpu_device_setdown(in_data, out_data, (^adb.GPU_Device_Setdown_Extra)(extra))
    case .SMART_PRE_RENDER:
        err = smart_pre_render(in_data, out_data, (^adb.Pre_Render_Extra)(extra))
    case .SMART_RENDER_GPU:
        err = smart_render(in_data, out_data, (^adb.Smart_Render_Extra)(extra))
    }

    return err
}
