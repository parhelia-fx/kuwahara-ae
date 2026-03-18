@echo off

cd /d "%~dp0"

call vcvars64.bat >nul

REM rc file
cl /I "AAE_SDK\Headers" /EP "Plugin.r" > "bin\Plugin.rr"
"AAE_SDK\Resources\PiPLTool.exe" "bin\Plugin.rr" "bin\Plugin.rrc"
cl /D "MSWindows" /EP "bin\Plugin.rrc" > "Plugin.rc"
del "bin\Plugin.rr"
del "bin\Plugin.rrc"

REM cuda stub
nvcc -c src/cuda_stub.cu -o bin/cuda_stub.o
lib /OUT:bin/cuda_stub.lib bin/cuda_stub.o

REM shaders
slangc -force-glsl-scalar-layout -matrix-layout-column-major -fp-mode fast -Omaximal -gnone -target spirv src/shaders/effect.slang -o src/shaders/effect.spv

REM build aex
odin build src -build-mode:dll -o:speed -resource:Plugin.rc -out:bin/KuwaharaFilter.aex
