package dof

import "core:c/libc"
import "core:fmt"
import win "core:sys/windows"

import "vendor/adb"
import "vendor:glfw"
import vk "vendor:vulkan"

GPU_Context :: struct {
    allocator: ^vk.AllocationCallbacks,
    dbg_msg: vk.DebugUtilsMessengerEXT,
    instance: vk.Instance,
    physical_device: vk.PhysicalDevice,
    physical_properties: vk.PhysicalDeviceProperties,
    physical_mem_props: vk.PhysicalDeviceMemoryProperties,
    device: vk.Device,

    queue_family_index: u32,
    queue: vk.Queue,
}

gpu_ctx: GPU_Context

GPU_Pipeline :: struct {
    shader: vk.ShaderModule,
    layout: vk.PipelineLayout,
    handle: vk.Pipeline,
}
gpu_pipeline: GPU_Pipeline

vk_allocator_info := vk.AllocationCallbacks {
    pfnAllocation = auto_cast vulkan_alloc,
    pfnFree = vulkan_free,
    pfnReallocation = auto_cast vulkan_realloc,
}

vk_check :: proc(result: vk.Result) {
    when ODIN_DEBUG {
        assert(result == .SUCCESS)
    }
}

debug_message :: proc "system" (
    message_severity: vk.DebugUtilsMessageSeverityFlagsEXT,
    message_types: vk.DebugUtilsMessageTypeFlagsEXT,
    callback_data: ^vk.DebugUtilsMessengerCallbackDataEXT,
    user_data: rawptr
) -> b32 {
    if .INFO in message_severity {
        libc.fprintf(libc.stderr, "[INFO] ")
    } else if .WARNING in message_severity {
        libc.fprintf(libc.stderr, "[WARN] ")
    } else if .ERROR in message_severity {
        libc.fprintf(libc.stderr, "[ERR] ")
    } else {
        /* don't care about verbose */
        return false
    }

    if .GENERAL in message_types {
        libc.fprintf(libc.stderr, "\\-General-/ ")
    } else if .VALIDATION in message_types {
        libc.fprintf(libc.stderr, "\\-Validation-/ ")
    } else if .PERFORMANCE in message_types {
        libc.fprintf(libc.stderr, "\\-Performance-/ ")
    }

    libc.fprintf(libc.stderr, "%s\n", callback_data.pMessage)
    return false
}

gpu_init :: proc() -> GPU_Context {
    vk_allocator := &vk_allocator_info
    // vk_allocator: ^vk.AllocationCallbacks = nil

    // TODO: make this work on macos as well
    module := win.LoadLibraryW(win.L("vulkan-1.dll"))
    vk_get_instance_proc_addr := win.GetProcAddress(module, "vkGetInstanceProcAddr")
    vk.load_proc_addresses_global(vk_get_instance_proc_addr)

    debug_utils_ci := vk.DebugUtilsMessengerCreateInfoEXT {
            sType = .DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
            messageSeverity = {.ERROR, .WARNING, .INFO},
            messageType = {.GENERAL, .PERFORMANCE, .VALIDATION},
            pfnUserCallback = debug_message,
    }

    instance: vk.Instance
    {
        app_info := vk.ApplicationInfo {
            sType = .APPLICATION_INFO,
            apiVersion = vk.API_VERSION_1_3,
        }
        ci := vk.InstanceCreateInfo {
            sType = .INSTANCE_CREATE_INFO,
            pApplicationInfo = &app_info,
        }

        layers: [1]cstring = {"VK_LAYER_KHRONOS_validation"}
        extensions: [1]cstring = {"VK_EXT_debug_utils"}
        when ODIN_DEBUG {
            ci.pNext = &debug_utils_ci
            ci.enabledLayerCount = len(layers)
            ci.ppEnabledLayerNames = raw_data(layers[:])
            ci.enabledExtensionCount = len(extensions)
            ci.ppEnabledExtensionNames = raw_data(extensions[:])
        }

        vk_check(vk.CreateInstance(&ci, vk_allocator, &instance))
    }

    vk.load_proc_addresses_instance(instance)

    dbg_msg: vk.DebugUtilsMessengerEXT
    when ODIN_DEBUG {
        vk_check(vk.CreateDebugUtilsMessengerEXT(instance, &debug_utils_ci, vk_allocator, &dbg_msg))
    }

    // Pick physical device (first detected)
    // TODO: More robust selection (Pick dedicated gpu with highest vram)
    physical_device: vk.PhysicalDevice
    physical_properties: vk.PhysicalDeviceProperties
    physical_mem_props: vk.PhysicalDeviceMemoryProperties
    {
        physical_device_count: u32 = 16
        physical_devices: [16]vk.PhysicalDevice
        vk.EnumeratePhysicalDevices(
                instance,
                &physical_device_count,
                &physical_devices[0],
        )
        physical_device = physical_devices[0]
        vk.GetPhysicalDeviceProperties(physical_device, &physical_properties)
        vk.GetPhysicalDeviceMemoryProperties(physical_device, &physical_mem_props)
    }

    queue_family_index: u32
    {
        queue_family_count: u32 = 16
        queue_family_properties: [16]vk.QueueFamilyProperties
        vk.GetPhysicalDeviceQueueFamilyProperties(
            physical_device,
            &queue_family_count,
            &queue_family_properties[0]
        )

        for i in 0..<queue_family_count {
            properties := queue_family_properties[i]
            if .COMPUTE in properties.queueFlags && .GRAPHICS in properties.queueFlags {
                queue_family_index = i
                break
            }
        }
    }

    priority: f32 = 1
    queue_ci := vk.DeviceQueueCreateInfo {
        sType = .DEVICE_QUEUE_CREATE_INFO,
        queueFamilyIndex = queue_family_index,
        queueCount = 1,
        pQueuePriorities = &priority
    }

    device: vk.Device
    {
        features12 := vk.PhysicalDeviceVulkan12Features {
            sType = .PHYSICAL_DEVICE_VULKAN_1_2_FEATURES,
            bufferDeviceAddress = true,
            scalarBlockLayout = true,
        }
        ci := vk.DeviceCreateInfo {
            sType = .DEVICE_CREATE_INFO,
            pNext = &features12,
            queueCreateInfoCount = 1,
            pQueueCreateInfos = &queue_ci,
        }
        vk_check(vk.CreateDevice(physical_device, &ci, vk_allocator, &device))
    }

    vk.load_proc_addresses_device(device)

    queue: vk.Queue
    {
        vk.GetDeviceQueue(device, queue_family_index, 0, &queue)
    }

    return {
        instance = instance,
        physical_device = physical_device,
        physical_properties = physical_properties,
        physical_mem_props = physical_mem_props,
        device = device,
        queue_family_index = queue_family_index,
        queue = queue,
    }
}

gpu_uninit :: proc(ctx: ^GPU_Context) {
    vk.DestroyDevice(ctx.device, ctx.allocator)
    when ODIN_DEBUG do vk.DestroyDebugUtilsMessengerEXT(ctx.instance, ctx.dbg_msg, ctx.allocator)
    vk.DestroyInstance(ctx.instance, ctx.allocator)

    ctx^ = {}
}

gpu_pipeline_init :: proc(ctx: GPU_Context, data_size: u32) -> GPU_Pipeline {
    ctx := ctx

    shader_code := #load("shaders/effect.spv", []u32)
    shader: vk.ShaderModule
    {
        ci := vk.ShaderModuleCreateInfo {
            sType = .SHADER_MODULE_CREATE_INFO,
            codeSize = len(shader_code) * size_of(shader_code[0]),
            pCode = raw_data(shader_code),
        }
        vk_check(vk.CreateShaderModule(ctx.device, &ci, ctx.allocator, &shader))
    }

    pipeline_layout: vk.PipelineLayout
    {
        push_constant_range := vk.PushConstantRange {
            stageFlags = {.COMPUTE},
            offset = 0,
            size = data_size,
        }
        ci := vk.PipelineLayoutCreateInfo {
            sType = .PIPELINE_LAYOUT_CREATE_INFO,
            pushConstantRangeCount = 1,
            pPushConstantRanges = &push_constant_range,
        }

        vk_check(vk.CreatePipelineLayout(ctx.device, &ci, ctx.allocator, &pipeline_layout))
    }

    pipeline: vk.Pipeline
    {
        shader_stage_ci := vk.PipelineShaderStageCreateInfo {
            sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
            stage = {.COMPUTE},
            module = shader,
            pName = "main",
        }
        ci := vk.ComputePipelineCreateInfo {
            sType = .COMPUTE_PIPELINE_CREATE_INFO,
            stage = shader_stage_ci,
            layout = pipeline_layout,
        }

        vk_check(vk.CreateComputePipelines(ctx.device, 0, 1, &ci, ctx.allocator, &pipeline))
    }

    return {
        shader = shader,
        layout = pipeline_layout,
        handle = pipeline,
    }
}

gpu_pipeline_uninit :: proc(ctx: GPU_Context, pipeline: ^GPU_Pipeline) {
    vk.DestroyPipeline(ctx.device, pipeline.handle, ctx.allocator)
    vk.DestroyPipelineLayout(ctx.device, pipeline.layout, ctx.allocator)
    vk.DestroyShaderModule(ctx.device, pipeline.shader, ctx.allocator)

    pipeline^ = {}
}

gpu_synchronize :: proc(ctx: GPU_Context) {
    vk_check(vk.DeviceWaitIdle(ctx.device))
}

// Allocation

vulkan_alloc :: proc "system" (
    pUserData: rawptr,
    size: uint,
    alignment: uint,
    allocationScope: vk.SystemAllocationScope
) -> rawptr {
    ptr: rawptr
    err := suites.basic_suite.allocate_block(size, &ptr)
    if err != 0 do return nil
    return ptr
}

vulkan_free :: proc "system" (pUserData: rawptr, pMemory: rawptr) {
    suites.basic_suite.free_block(pMemory)
}

vulkan_realloc :: proc "system" (
    pUserData: rawptr,
    pOriginal: rawptr,
    size: uint,
    alignment: uint,
    allocationScope: vk.SystemAllocationScope
) -> rawptr {
    ptr: rawptr
    err := suites.basic_suite.reallocate_block(pOriginal, size, &ptr)
    if err != 0 do return nil
    return ptr
}
