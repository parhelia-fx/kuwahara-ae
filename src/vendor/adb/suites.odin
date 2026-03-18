package adb

import "core:c"

Iterate8_Suite1 :: struct #align (8) {
    iterate:                     proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        refcon: rawptr,
        pix_fn: proc "c" (refcon: rawptr, x, y: i32, inP: ^Pixel, outP: ^Pixel) -> Err,
        dst: ^Effect_World,
    ) -> Err,
    iterate_origin:              proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        origin: ^Point,
        refcon: rawptr,
        pix_fn: proc "c" (refcon: rawptr, x, y: i32, inP: ^Pixel, outP: ^Pixel) -> Err,
        dst: ^Effect_World,
    ) -> Err,
    iterate_lut:                 proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        a_lut0, r_lut0, g_lut0, b_lut0: ^u8,
        dst: ^Effect_World,
    ) -> Err,
    iterate_origin_non_clip_src: proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        origin: ^Point,
        refcon: rawptr,
        pix_fn: proc "c" (refcon: rawptr, x, y: i32, inP: ^Pixel, outP: ^Pixel) -> Err,
        dst: ^Effect_World,
    ) -> Err,
    iterate_generic:             proc "c" (
        iterationsL: i32,
        refcon: rawptr,
        fn_func: proc "c" (refcon: rawptr, thread_indexL, i, iterationsL: i32) -> Err,
    ) -> Err,
}

Iterate16_Suite1 :: struct #align (8) {
    iterate:                     proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        refcon: rawptr,
        pix_fn: proc "c" (refcon: rawptr, x, y: i32, inP: ^Pixel16, outP: ^Pixel16) -> Err,
        dst: ^Effect_World,
    ) -> Err,
    iterate_origin:              proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        origin: ^Point,
        refcon: rawptr,
        pix_fn: proc "c" (refcon: rawptr, x, y: i32, inP: ^Pixel16, outP: ^Pixel16) -> Err,
        dst: ^Effect_World,
    ) -> Err,
    iterate_origin_non_clip_src: proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        origin: ^Point,
        refcon: rawptr,
        pix_fn: proc "c" (refcon: rawptr, x, y: i32, inP: ^Pixel16, outP: ^Pixel16) -> Err,
        dst: ^Effect_World,
    ) -> Err,
}

Iterate_Float_Suite1 :: struct {
    iterate:                     proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        refcon: rawptr,
        pix_fn: proc "c" (refcon: rawptr, x, y: i32, inP: ^Pixel32, outP: ^Pixel32) -> Err,
        dst: ^Effect_World,
    ) -> Err,
    iterate_origin:              proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        origin: ^Point,
        refcon: rawptr,
        pix_fn: proc "c" (refcon: rawptr, x, y: i32, inP: ^Pixel32, outP: ^Pixel32) -> Err,
        dst: ^Effect_World,
    ) -> Err,
    iterate_origin_non_clip_src: proc "c" (
        in_data: ^In_Data,
        progress_base, progress_final: i32,
        src: ^Effect_World,
        area: ^Rect,
        origin: ^Point,
        refcon: rawptr,
        pix_fn: proc "c" (refcon: rawptr, x, y: i32, inP: ^Pixel32, outP: ^Pixel32) -> Err,
        dst: ^Effect_World,
    ) -> Err,
}

Iterate8_Suite2 :: Iterate8_Suite1
Iterate16_Suite2 :: Iterate16_Suite1
Iterate_Float_Suite2 :: Iterate_Float_Suite1

Sampling8_Suite1 :: struct #align (8) {
    nn_sample:       proc "c" (
        effect_ref: ^Progress_Info,
        x, y: Fixed,
        params: ^Samp_PB,
        dst_pixel: ^Pixel,
    ) -> Err,
    subpixel_sample: proc "c" (
        effect_ref: ^Progress_Info,
        x, y: Fixed,
        params: ^Samp_PB,
        dst_pixel: ^Pixel,
    ) -> Err,
    area_sample:     proc "c" (
        effect_ref: ^Progress_Info,
        x, y: Fixed,
        params: ^Samp_PB,
        dst_pixel: ^Pixel,
    ) -> Err,
}

Sampling16_Suite1 :: struct #align (8) {
    nn_sample:       proc "c" (
        effect_ref: ^Progress_Info,
        x, y: Fixed,
        params: ^Samp_PB,
        dst_pixel: ^Pixel16,
    ) -> Err,
    subpixel_sample: proc "c" (
        effect_ref: ^Progress_Info,
        x, y: Fixed,
        params: ^Samp_PB,
        dst_pixel: ^Pixel16,
    ) -> Err,
    area_sample:     proc "c" (
        effect_ref: ^Progress_Info,
        x, y: Fixed,
        params: ^Samp_PB,
        dst_pixel: ^Pixel16,
    ) -> Err,
}

Sampling_Float_Suite1 :: struct #align (8) {
    nn_sample:       proc "c" (
        effect_ref: ^Progress_Info,
        x, y: Fixed,
        params: ^Samp_PB,
        dst_pixel: ^Pixel32,
    ) -> Err,
    subpixel_sample: proc "c" (
        effect_ref: ^Progress_Info,
        x, y: Fixed,
        params: ^Samp_PB,
        dst_pixel: ^Pixel32,
    ) -> Err,
    area_sample:     proc "c" (
        effect_ref: ^Progress_Info,
        x, y: Fixed,
        params: ^Samp_PB,
        dst_pixel: ^Pixel32,
    ) -> Err,
}

AEGP_World_Suite2 :: struct #align (8) {
    new_world:        proc "c" (
        effect_ref: ^Progress_Info,
        width, height: i32,
        clear_pix: b8,
        pixel_format: Pixel_Format,
        world: ^Effect_World,
    ) -> Err,
    dispose_world:    proc "c" (effect_ref: ^Progress_Info, world: ^Effect_World) -> Err,
    get_pixel_format: proc "c" (effect_ref: ^Progress_Info, pixel_format: ^Pixel_Format) -> Err,
}

Handle_Suite1 :: struct #align (8) {
    host_new_handle: proc "c" (size: u64) -> Handle,
    host_lock_handle: proc "c" (handle: Handle) -> rawptr,
    host_unlock_handle: proc "c" (handle: Handle),
    host_dispose_handle: proc "c" (handle: Handle),
    host_get_handle_size: proc "c" (handle: Handle) -> u64,
    host_resize_handle: proc "c" (new_size: u64, handle: ^Handle) -> Err,
}

/*

	PF_Err (*PF_NewWorld)(
		PF_ProgPtr			effect_ref,				/* reference from in_data */
		A_long				widthL,
		A_long				heightL,
		PF_Boolean			clear_pixB,
		PF_PixelFormat		pixel_format,
		PF_EffectWorld		*worldP);		

	PF_Err (*PF_DisposeWorld)(
		PF_ProgPtr			effect_ref,				/* reference from in_data */
		PF_EffectWorld		*worldP);


	PF_Err (*PF_GetPixelFormat)(
		const PF_EffectWorld		*worldP,				/* the pixel buffer of interest */
		PF_PixelFormat				*pixel_formatP);		/* << OUT. one of the above PF_PixelFormat types */


*/

World_Suite2 :: struct #align (8) {
    new_world: proc "c" (
        effect_ref: ^Progress_Info,
        width: i32,
        height: i32,
        clear_pix: b8,
        pixel_format: Pixel_Format,
        world: ^Effect_World,
    ) -> Err,
    dispose_world: proc "c" (
        effect_ref: ^Progress_Info,
        world: ^Effect_World,
    ) -> Err,
    get_pixel_format: proc "c" (
        world: ^Effect_World,
        pixel_format: ^Pixel_Format,
    ) -> Err,
}

/*
typedef struct PF_GPUDeviceSuite1 {

	/**
	**	This will return the number of gpu devices the host supports.
	**
	**	@param	effect_ref								Comes with PF_InData. 
	**	@param	device_countP							Return number of devices available.
	*/
	SPAPI PF_Err	(*GetDeviceCount)( 					PF_ProgPtr			effect_ref,
														A_u_long			*device_countP);	/* << */

	/**
	**	This will return the device info with given device index, which includes necessary context/queue information
	**	needed to dispatch task to the device. Refer PF_GPUDeviceInfo for details.
	**
	**	@param	effect_ref								Comes with PF_InData. 
	**	@param	device_index							The device index for the requested device.
	**	@param	PF_GPUDeviceInfo						The device info will to be filled.
	*/
	SPAPI PF_Err	(*GetDeviceInfo)( 					PF_ProgPtr			effect_ref,
														A_u_long			device_index,
									  					PF_GPUDeviceInfo	*device_infoP);	/* << */


	/**
	**	Acquire/release exclusive access to inDeviceIndex. All calls below this point generally require access be held.
	**	For full GPU plugins (those that use a separate entry point for GPU rendering) exclusive access is always held.
	**	These calls do not need to be made in that case.
	**		For CUDA calls cuCtxPushCurrent/cuCtxPopCurrent on the current thread to manage the devices context.
	*/
	SPAPI PF_Err	(*AcquireExclusiveDeviceAccess)( 	PF_ProgPtr			effect_ref,
														A_u_long			device_index);

	SPAPI PF_Err	(*ReleaseExclusiveDeviceAccess)( 	PF_ProgPtr			effect_ref,
														A_u_long			device_index);

	/**
	**	All device memory must be allocated through this suite.
	**		Purge should be called only in emergency situations when working with GPU memory
	**			that cannot be allocated through this suite (eg OpenGL memory).
	**		Returned pointer value represents memory allocated through cuMemAlloc or clCreateBuffer or CreateCommittedResource.
	*/

	SPAPI PF_Err	(*AllocateDeviceMemory)(	PF_ProgPtr			effect_ref,
	 											A_u_long			device_index,
											 	size_t				size_bytes,
												void 				**memoryPP);	/* << */

	SPAPI PF_Err	(*FreeDeviceMemory)( 		PF_ProgPtr			effect_ref,
												A_u_long			device_index,
										 		void         	  	*memoryP);

	SPAPI PF_Err	(*PurgeDeviceMemory)( 		PF_ProgPtr			effect_ref,
												A_u_long			device_index,
										  		size_t				size_bytes,
										 	 	size_t 				*bytes_purgedP0);	/* << */

	/**
	**	All host (pinned) memory must be allocated through this suite.
	**		Purge should be called only in emergency situations when working with GPU memory
	**			that cannot be allocated through this suite (eg OpenGL memory).
	**		Returned pointer value represents memory allocated through cuMemHostAlloc or malloc or CreateCommittedResource (on upload heap).
	*/
	SPAPI PF_Err	(*AllocateHostMemory)(	PF_ProgPtr			effect_ref,
											A_u_long			device_index,
											size_t				size_bytes,
											void 				**memoryPP);	/* << */


	SPAPI PF_Err	(*FreeHostMemory)( 		PF_ProgPtr			effect_ref,
											A_u_long			device_index,
											void				*memoryP);


	SPAPI PF_Err	(*PurgeHostMemory)( 	PF_ProgPtr			effect_ref,	
											A_u_long			device_index,
											size_t				bytes_to_purge,
											size_t 				*bytes_purgedP0);	/* << */

	/**
	**	This will allocate a gpu effect world. Caller is responsible for deallocating the buffer with
	**	PF_GPUDeviceSuite1::DisposeGPUWorld.
	**
	**	@param	effect_ref					Comes with PF_InData. 
	**	@param	device_index				The device you want your gpu effect world allocated with.
	**	@param	width						Width of the effect world.
	**	@param	height						Height of the effect world.
	**	@param	pixel_aspect_ratio			Pixel Aspect Ratio of the effect world.
	**	@param	field_type					The field of the effect world.
	**	@param	pixel_format				The pixel format of the effect world, only gpu formats are accepted.
	**	@param	clear_pixB					Pass in 'true' for a transparent black frame.
	**	@param	worldPP						The handle to the effect world to be created.
	*/
	SPAPI PF_Err	(*CreateGPUWorld)(		PF_ProgPtr			effect_ref,
											A_u_long			device_index,
											A_long				width,
											A_long				height,
											PF_RationalScale	pixel_aspect_ratio,
											PF_Field 			field_type,
											PF_PixelFormat		pixel_format,
											PF_Boolean			clear_pixB,
											PF_EffectWorld		**worldPP);	/* << */


	/**
	**	This will free this effect world. The effect world is no longer valid after this function is called.
	**	Plugin module is only allowed to dispose of effect worlds they create.
	**
	**	@param	effect_ref					Comes with PF_InData. 
	**	@param	worldP						The effect world you want to dispose.
	*/
	SPAPI PF_Err	(*DisposeGPUWorld)(		PF_ProgPtr			effect_ref,
											PF_EffectWorld		*worldP);


	/**
	**	This will return the gpu buffer address of the given effect world.
	**
	**	@param	effect_ref						Comes with PF_InData. 
	**	@param	worldP							The effect world you want to operate on, has to be a gpu effect world.
	**	@param	pixPP							Returns the gpu buffer address.
	*/
	SPAPI PF_Err	(*GetGPUWorldData)(			PF_ProgPtr			effect_ref,
												PF_EffectWorld		*worldP,
												void				**pixPP);	/* << */

	/**
	**	This will return the size of the total data in the effect world.
	**
	**	@param	effect_ref						Comes with PF_InData.
	**	@param	worldP							The effect world you want to operate on, has to be a gpu effect world.
	**	@param	device_indexP					Returns the size of the total data in the effect world.
	*/
	SPAPI PF_Err	(*GetGPUWorldSize)( 		PF_ProgPtr			effect_ref,
												PF_EffectWorld		*worldP,
												size_t				*size_in_bytesP);	/* << */


	/**
	**	This will return device index the gpu effect world is associated with.
	**
	**	@param	effect_ref						Comes with PF_InData. 
	**	@param	worldP							The effect world you want to operate on, has to be a gpu effect world.
	**	@param	device_indexP					Returns the device index of the given effect world.
	*/
	SPAPI PF_Err	(*GetGPUWorldDeviceIndex)( 	PF_ProgPtr			effect_ref,
												PF_EffectWorld		*worldP,
												A_u_long			*device_indexP);	/* << */


} PF_GPUDeviceSuite1;
*/

GPU_Device_Suite1 :: struct #align (8) {
    get_device_count: proc "c" (
        effect_ref: ^Progress_Info,
        device_count: ^u32,
    ) -> Err,
    get_device_info: proc "c" (
        effect_ref: ^Progress_Info,
        device_index: u32,
        device_info: ^GPU_Device_Info,
    ) -> Err,
    acquire_exclusive_device_access: proc "c" (
        effect_ref: ^Progress_Info,
        device_index: u32,
    ) -> Err,
    release_exclusive_device_access: proc "c" (
        effect_ref: ^Progress_Info,
        device_index: u32,
    ) -> Err,
    allocate_device_memory: proc "c" (
        effect_ref: ^Progress_Info,
        device_index: u32,
        size_bytes: uint,
        memory: ^rawptr,
    ) -> Err,
    free_device_memory: proc "c" (
        effect_ref: ^Progress_Info,
        device_index: u32,
        memory: rawptr,
    ) -> Err,
    purge_device_memory: proc "c" (
        effect_ref: ^Progress_Info,
        device_index: u32,
        size_bytes: uint,
        bytes_purged: ^uint,
    ) -> Err,
    allocate_host_memory: proc "c" (
        effect_ref: ^Progress_Info,
        device_index: u32,
        size_bytes: uint,
        memory: ^rawptr,
    ) -> Err,
    free_host_memory: proc "c" (
        effect_ref: ^Progress_Info,
        device_index: u32,
        memory: rawptr,
    ) -> Err,
    purge_host_memory: proc "c" (
        effect_ref: ^Progress_Info,
        device_index: u32,
        bytes_to_purge: uint,
        bytes_purged: ^uint,
    ) -> Err,
    create_gpu_world: proc "c" (
        effect_ref: ^Progress_Info,
        device_index: u32,
        width: i32,
        height: i32,
        pixel_aspect_ratio: Rational_Scale,
        field_type: Field,
        pixel_format: Pixel_Format,
        clear_pix: b8,
        world: ^^Effect_World,
    ) -> Err,
    dispose_gpu_world: proc "c" (
        effect_ref: ^Progress_Info,
        world: ^Effect_World,
    ) -> Err,
    get_gpu_world_data: proc "c" (
        effect_ref: ^Progress_Info,
        world: ^Effect_World,
        pix: ^rawptr,
    ) -> Err,
    get_gpu_world_size: proc "c" (
        effect_ref: ^Progress_Info,
        world: ^Effect_World,
        size_in_bytes: ^uint,
    ) -> Err,
    get_gpu_world_device_index: proc "c" (
        effect_ref: ^Progress_Info,
        world: ^Effect_World,
        device_index: ^u32,
    ) -> Err,
}
#assert(size_of(GPU_Device_Suite1) == 120)

/*
typedef struct PF_ANSICallbacksSuite1 {
		A_FpLong	(*atan)(A_FpLong);
		A_FpLong	(*atan2)(A_FpLong y, A_FpLong x);	/* returns atan(y/x) - note param order! */
		A_FpLong	(*ceil)(A_FpLong);				/* returns next int above x */
		A_FpLong	(*cos)(A_FpLong);
		A_FpLong	(*exp)(A_FpLong);					/* returns e to the x power */
		A_FpLong	(*fabs)(A_FpLong);				/* returns absolute value of x */
		A_FpLong	(*floor)(A_FpLong);				/* returns closest int below x */
		A_FpLong	(*fmod)(A_FpLong x, A_FpLong y);	/* returns x mod y */
		A_FpLong	(*hypot)(A_FpLong x, A_FpLong y);	/* returns sqrt(x*x + y*y) */
		A_FpLong	(*log)(A_FpLong);					/* returns natural log of x */
		A_FpLong	(*log10)(A_FpLong);				/* returns log base 10 of x */
		A_FpLong	(*pow)(A_FpLong x, A_FpLong y);		/* returns x to the y power */
		A_FpLong	(*sin)(A_FpLong);
		A_FpLong	(*sqrt)(A_FpLong);
		A_FpLong	(*tan)(A_FpLong);

		int		(*sprintf)(A_char *, const A_char *, ...);
		A_char *	(*strcpy)(A_char *, const A_char *);

		A_FpLong (*asin)(A_FpLong);
		A_FpLong (*acos)(A_FpLong);
	
} PF_ANSICallbacksSuite1;
*/

ANSI_Callbacks_Suite1 :: struct #align(8) {
    atan: proc "c" (x: f64) -> f64,
    atan2: proc "c" (y, x: f64) -> f64,
    ceil: proc "c" (x: f64) -> f64,
    cos: proc "c" (x: f64) -> f64,
    exp: proc "c" (x: f64) -> f64,
    fabs: proc "c" (x: f64) -> f64,
    floor: proc "c" (x: f64) -> f64,
    fmod: proc "c" (x, y: f64) -> f64,
    hypot: proc "c" (x, y: f64) -> f64,
    log: proc "c" (x: f64) -> f64,
    log10: proc "c" (x: f64) -> f64,
    pow: proc "c" (x, y: f64) -> f64,
    sin: proc "c" (x: f64) -> f64,
    sqrt: proc "c" (x: f64) -> f64,
    tan: proc "c" (x: f64) -> f64,

    sprintf: proc "c" (s: [^]u8, format: cstring, arg: ^c.va_list) -> i32,
    strcpy: proc "c" (dst: [^]u8, src: cstring) -> [^]u8,

    asin: proc "c" (x: f64) -> f64,
    acos: proc "c" (x: f64) -> f64,
}
#assert(size_of(ANSI_Callbacks_Suite1) == 152)

Suites :: struct {
    basic_suite:           ^SP_Basic_Suite,
    aegp_world_suite2:     ^AEGP_World_Suite2,
    handle_suite1:         ^Handle_Suite1,
    world_suite2:          ^World_Suite2,
    gpu_device_suite1:     ^GPU_Device_Suite1,
}
