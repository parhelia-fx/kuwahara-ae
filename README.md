# Kuwahara Filter for Adobe After Effects

`kuwahara-ae` is a plugin for Adobe After Effects implementing the
[Kuwahara filter](https://en.wikipedia.org/wiki/Kuwahara_filter).

It is GPU accelerated using Vulkan, which allows for cross-platform shader support using [Slang](https://shader-slang.org/).

The Adobe After Effects SDK does not provide direct support for Vulkan, thus requiring plugin vendors to write
multiple implementations of their effects in order to support all platforms.

By advertising GPU support to After Effects and operating directly on GPU memory, the plugin
achieves no unnecessary CPU<->GPU memory copy operations.

## Dependencies:

- [Odin](https://odin-lang.org/)
- [Adobe After Effects SDK](https://developer.adobe.com/after-effects/)
- [Slang](https://shader-slang.org/)
- (Nvidia only) [CUDA v12.9 SDK](https://developer.nvidia.com/cuda-12-9-1-download-archive)
- (Windows only) [Visual Studio](https://visualstudio.microsoft.com/)

## Building

Clone the repository:
```bash
git clone https://github.com/parhelia-fx/kuwahara-ae.git
```
Place the Adobe After Effects SDK inside of a folder named `AAE_SDK/` such that the
`AAE_SDK/Resources` path is valid.

Make sure `nvcc`, `slangc`, and `odin` are in your PATH and
use the `x64 Native Tools Command Prompt` environment provided by Visual Studio.

To build, simply run `build.bat`. The `.aex` plugin binary will be output to the `bin/` directory.

## TODO

While shaders are cross-platform, extra glue code is required on the host side to support other platforms.

- [ ] MacOS support
- [ ] OpenCL support
