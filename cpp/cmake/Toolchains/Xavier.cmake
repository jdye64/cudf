set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_SYSROOT /home/jdyer/nvidia/nvidia_sdk/JetPack_4.4_DP_Linux_DP_JETSON_AGX_XAVIER/Linux_for_Tegra/rootfs)
set(CMAKE_STAGING_PREFIX /home/jdyer/xavier_staging_dir)

set(tools /home/jdyer/Development/xavier_cross_compile_toolchain_latest)
set(CMAKE_C_COMPILER ${tools}/bin/aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER ${tools}/bin/aarch64-linux-gnu-g++)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)