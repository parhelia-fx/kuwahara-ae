package dof

import "core:sys/windows"

import vk "vendor:vulkan"

when ODIN_OS == .Windows do foreign import cuda {"../bin/cuda_stub.lib", "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.9/lib/x64/cudart_static.lib"}

foreign cuda {
    cuda_device_synchronize :: proc "c" () ---
}

effect_render :: proc(ctx: ^GPU_Context, pipeline: GPU_Pipeline, data: Effect_GPU_Data) {
    data := data

    // allocate command pool
    command_pool: vk.CommandPool
    {
        ci := vk.CommandPoolCreateInfo {
            sType = .COMMAND_POOL_CREATE_INFO,
            flags = {},
            queueFamilyIndex = ctx.queue_family_index,
        }
        vk_check(vk.CreateCommandPool(ctx.device, &ci, ctx.allocator, &command_pool))
    }

    // allocate command buffer
    cmd_buffer: vk.CommandBuffer
    {
        ci := vk.CommandBufferAllocateInfo {
            sType = .COMMAND_BUFFER_ALLOCATE_INFO,
            commandPool = command_pool,
            level = .PRIMARY,
            commandBufferCount = 1,
        }
        vk_check(vk.AllocateCommandBuffers(ctx.device, &ci, &cmd_buffer))
    }

    // fence
    fence: vk.Fence
    {
        ci := vk.FenceCreateInfo {
            sType = .FENCE_CREATE_INFO,
        }
        vk_check(vk.CreateFence(ctx.device, &ci, ctx.allocator, &fence))
    }

    // record dispatch
    begin_info := vk.CommandBufferBeginInfo {
        sType = .COMMAND_BUFFER_BEGIN_INFO,
        flags = {.ONE_TIME_SUBMIT},
    }
    vk_check(vk.BeginCommandBuffer(cmd_buffer, &begin_info))

    vk.CmdBindPipeline(cmd_buffer, .COMPUTE, pipeline.handle)
    vk.CmdPushConstants(cmd_buffer, pipeline.layout, {.COMPUTE}, 0, size_of(data), &data)

    divide_round_up :: proc (val: u32, multiple: u32) -> u32 {
        if multiple != 0 {
            return (val + multiple - 1) / multiple
        } else {
            return 0
        }
    }
    group_count_x := divide_round_up(data.width, 16)
    group_count_y := divide_round_up(data.height, 16)
    vk.CmdDispatch(cmd_buffer, group_count_x, group_count_y, 1)

    vk_check(vk.EndCommandBuffer(cmd_buffer))

    // submit to queue
    submit_info := vk.SubmitInfo {
        sType = .SUBMIT_INFO,
        waitSemaphoreCount = 0,
        commandBufferCount = 1,
        pCommandBuffers = &cmd_buffer,
        signalSemaphoreCount = 0,
    }

    cuda_device_synchronize()
    vk_check(vk.QueueSubmit(ctx.queue, 1, &submit_info, fence))

    vk_check(vk.WaitForFences(ctx.device, 1, &fence, true, max(u64)))

    // clean up
    vk.DestroyFence(ctx.device, fence, ctx.allocator)
    vk.DestroyCommandPool(ctx.device, command_pool, ctx.allocator)
}
