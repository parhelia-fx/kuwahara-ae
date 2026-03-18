#include "cuda_runtime.h"

extern "C" void cuda_device_synchronize() {
    cudaDeviceSynchronize();
}