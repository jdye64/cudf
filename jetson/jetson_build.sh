#!/bin/bash

# Copyright (c) 2020, NVIDIA CORPORATION.

# TODO List:
# 1) Allow user to specify base BUILD_ROOT and if not specified default to ~/Development
# 2) Function to print runtimes instead of so many if...else statements scattered throughout the script

# First ensure this script as ran with root permissions
if [[ $EUID > 0 ]]
    then echo "Please run this script as root"
    exit 1
else
    # Since we are running as root their are a few environment variables we need to adjust
    export PATH=${PATH}:/usr/local/cuda/bin
fi

# Abort script on first error
set -e

NUMARGS=$#
ARGS=$*
CWORKDIR=$(cd $(dirname $0); pwd)

VALIDARGS="clean cudf tests -v -h -skip_deps -skip_prep_env -silent_times"
HELP="$0 [clean] [cudf] [tests] [-v] [-g] [-skip_deps] [-skip_prep_env] [-silent_times]
   clean            - remove all existing build artifacts and configurations (start over)
   cudf             - build libcudf C++ and cudf python code
   -skip_deps       - skips installing dependencies. useful if the dependencies have been installed via previous runs
   -skip_prep_env   - skips preparing the build environment. useful if codebase and environment variables are already set of have manually configured values desired
   -silent_times    - do not output the time taken by each step of the script
   -v               - verbose build mode
   -h               - print this text
   default action (no args) is to build and install the 'cudf' target
"

# Checks for the existance of an argument
function hasArg {
    (( ${NUMARGS} != 0 )) && (echo " ${ARGS} " | grep -q " $1 ")
}

# Check for valid usage
if (( ${NUMARGS} != 0 )); then
    for a in ${ARGS}; do
    if ! (echo " ${VALIDARGS} " | grep -q " ${a} "); then
        echo "Invalid option: ${a}"
        exit 1
    fi
    done
fi

# Output script help
if hasArg -h; then
    echo "${HELP}"
    exit 0
fi

if hasArg -silent_times; then
    SILENT_TIMES="ON"
else
    SILENT_TIMES="OFF"
fi

if hasArg -skip_deps; then
    SKIP_DEPS="ON"
else
    SKIP_DEPS="OFF"
fi

if hasArg -skip_prep_env; then
    SKIP_PREP_ENV="ON"
else
    SKIP_PREP_ENV="OFF"
fi

# Global Script Variables
BUILD_ALL=OFF
BUILD_CUDF=ON
BUILD_CUML=OFF # Not yet supported. Placed here to show intention

GLOBALTIME=$(date +%s)
BUILD_ROOT=~/Development
CMAKE_ROOT=$BUILD_ROOT/cmake
LLVM_ROOT=$BUILD_ROOT/llvm
LIBCUDF_BUILD_ROOT=$BUILD_ROOT/cudf/cpp/build
CUDF_BUILD_ROOT=$BUILD_ROOT/cudf/python/cudf

# Dependencies
DEFAULT_SYS_DEPS=("libssl-dev" "libboost-all-dev" "python3.7" "python3-pip")
DEFAULT_SYS_DEPS_TO_REMOVE=("python3-numpy" "python3-pandas")
DEFAULT_PIP_PACKAGES=("wheel" "cmake_setuptools" "llvmlite" "cython" "numpy" "numba==0.46.0" "fastavro" "fsspec" "pandas>=0.25,<0.26" "cupy")

# Types of Jetson Board types
BOARD_TYPES=( "t186ref:AGX Xavier Developer Board"
            "t186:AGX Xavier" )

# Cleans up the device from previous script runs
clean() {
    echo "Deleting everything in $BUILD_ROOT"
    rm -rf $BUILD_ROOT/*

    if [ "$SKIP_PREP_ENV" == "ON" ]; then
        echo "The contents of $BUILD_ROOT have been deleted but your run has '-skip_prep_env' option enabled. This could cause issues!"
    fi

    # Remove the Python dependencies. This must happen before pip3 is removed
    echo "Removing existing Python Pip packages"
    pip3 uninstall -y "${DEFAULT_PIP_PACKAGES[@]}"

    echo "Removing system installed dependencies"
    apt-get --purge remove -y "${DEFAULT_SYS_DEPS[@]}"

    # TODO: Remove everything from /etc/profile that was placed there by this script if applicable

    echo "Exiting ... Please run the script again without the clean flag to build"
    exit 1
}

# Queries the device for hardware and software information
query_device() {
    # Uname information
	UNAME_ALL="$(uname -a)"
    UNAME_KERNEL="$(uname -s)"
    UNAME_NODENAME="$(uname -n)"
    UNAME_KERNEL_RELEASE="$(uname -v)"
    UNAME_MACHINE="$(uname -m)"
    UNAME_PROCESSOR="$(uname -p)"
    UNAME_HARDWARE_PLATFORM="$(uname -i)"
    UNAME_OPERATING_SYSTEM="$(uname -o)"

    # Ensure CUDA is present
    # Attempt to locate NVCC in "odd places" in a future version. Should be on PATH by default however.
    command -v nvcc &>/dev/null || { echo >&2 "Unable to locate nvcc! Aborting."; exit 1; }
    CUDA_VERSION="$(nvcc --version)"

    # Determine the Jetson device type
    TEGRA_RELEASE_FILE=/etc/nv_tegra_release
    if [ -f "$TEGRA_RELEASE_FILE" ]; then
        BOARD_TYPE_KEY=
    else
        echo "$TEGRA_RELEASE_FILE does not exist. Unable to determine Jetson Board type. Are you attempting to run this script on a non Jetson device? Aborting."
        exit 1
    fi

    for board in "${BOARD_TYPES[@]}" ; do
        KEY=${board%%:*}
        bname=${board#*:}
        printf "%s likes to %s.\n" "$KEY" "$bname"
    done

    # echo -e "${ARRAY[1]%%:*} is an extinct animal which likes to ${ARRAY[1]#*:}\n"
}

# Prepares the device for the installation
prepare_device() {
    STARTTIME=$(date +%s)
	echo "Setting Xavier device power management to 'MAXN' for faster compilation"
	nvpmodel -m 0
    ENDTIME=$(date +%s)

    if [ "$SILENT_TIMES" == "OFF" ]; then
        echo "Device preparation took: $(($ENDTIME - $STARTTIME)) seconds to complete"
    fi
}

# Install system dependencies
install_dependencies() {
    STARTTIME=$(date +%s)
    echo "Install System Dependencies"

    # Default - apt system dependencies that are needed
	apt-get update -y
    apt-get install -y "${DEFAULT_SYS_DEPS[@]}"
	update-alternatives --install /usr/bin/python python /usr/bin/python3 10
    apt-get remove -y "${DEFAULT_SYS_DEPS_TO_REMOVE[@]}"

    # Default - CMake 3.16.2, apt version is 3.10 and minimum of 3.12 is required by Rapids
	mkdir -p $CMAKE_ROOT
	cd $CMAKE_ROOT
	wget https://nvidia-xavier.s3.amazonaws.com/cmake-3.16.2-Linux-aarch64.tar.gz
	# wget https://github.com/Kitware/CMake/releases/download/v3.16.2/cmake-3.16.2.tar.gz # source code for this binary build
	tar -xzvf ./cmake-3.16.2-Linux-aarch64.tar.gz
	cd cmake-3.16.2-Linux-aarch64
	export PATH="$(pwd)/bin:$PATH"

    # Default - LLVM 7.0.1 which is not available in apt
	mkdir -p $LLVM_ROOT
	cd $LLVM_ROOT
	# wget http://releases.llvm.org/7.0.1/llvm-7.0.1.src.tar.xz # source code for this binary build
	wget https://nvidia-xavier.s3.amazonaws.com/LLVM-7.0.1-Linux.tar.gz
	tar -xvf ./LLVM-7.0.1-Linux.tar.gz
	cd LLVM-7.0.1-Linux
	export LLVM_CONFIG="$(pwd)/bin/llvm-config"

    # Default - For now pip will be used to install python deps. Would like to explore other options
	pip3 install "${DEFAULT_PIP_PACKAGES[@]}"

    # CUDF - Dependencies
    if hasArg cudf; then
        echo "Building cuDF"
    fi

    if [ "$SILENT_TIMES" == "OFF" ]; then
        ENDTIME=$(date +%s)
        echo "Installing System Dependencies took: $(($ENDTIME - $STARTTIME)) seconds to complete"
    fi
}

# Setup build environment
prepare_build_env() {
    STARTTIME=$(date +%s)
    echo "Preparing build environment"

	export CUDA_HOME=/usr/local/cuda-10.2
	export CUDACXX=/usr/local/cuda-10.2/bin/nvcc
	export ARROW_HOME=$BUILD_ROOT/cudf/cpp/build/arrow/install
	export DLPACK_ROOT=$BUILD_ROOT/dlpack
	export DLPACK_INCLUDE=$BUILD_ROOT/dlpack/include

	mkdir -p $BUILD_ROOT

	# Clone cudf codebase
	# git clone https://github.com/rapidsai/cudf.git $BUILD_ROOT/cudf

	# Clone my branch until needed changes are merged
	git clone https://github.com/jdye64/cudf.git $BUILD_ROOT/cudf
	cd $BUILD_ROOT/cudf
	git checkout cudf_xavier
	git submodule update --init --remote --recursive

	# Clone dlpack dependency
	git clone https://github.com/dmlc/dlpack.git $BUILD_ROOT/dlpack
	export DLPACK_HOME=$BUILD_ROOT/dlpack

	# Clone and build rmm dependency codebase
	git clone https://github.com/rapidsai/rmm $BUILD_ROOT/rmm
	cd $BUILD_ROOT/rmm
	git submodule update --init --remote --recursive

	# Build RMM
	./build.sh

	mkdir -p $LIBCUDF_BUILD_ROOT

    if [ "$SILENT_TIMES" == "OFF" ]; then
        ENDTIME=$(date +%s)
        echo "Preparing build environment took: $(($ENDTIME - $STARTTIME)) seconds to complete"
    fi
}

# Build the desired Rapids libraries
build() {

    # Build libcudf and cudf python packages
    if buildAll || hasArg cudf; then
        STARTTIME=$(date +%s)
        echo "Building cuDF"
        cd $LIBCUDF_BUILD_ROOT
        cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
              -DBUILD_ALL_GPU_ARCH=0 \
              -DBUILD_NVTX=OFF \
              -DBUILD_TESTS=OFF \
              -DBUILD_LEGACY_TESTS=OFF \
              -DBUILD_BENCHMARKS=OFF \
              -DDISABLE_DEPRECATION_WARNING=ON \
              -DCMAKE_BUILD_TYPE=RELEASE \
              -DCMAKE_CXX11_ABI=ON ..
        make -j4
        make install

        # Set the Arrow install location for pip can install pyarrow
        export ARROW_HOME=$LIBCUDF_BUILD_ROOT/arrow/install
        pip3 install pyarrow==0.15.1

        cd $CUDF_BUILD_ROOT
        python setup.py build_ext --inplace
        python setup.py install --single-version-externally-managed --record=record.txt

        if [ "$SILENT_TIMES" == "OFF" ]; then
            ENDTIME=$(date +%s)
            echo "Building cuDF took: $(($ENDTIME - $STARTTIME)) seconds to complete"
        fi
    fi
}

# First clean before doing anything else if desired
if hasArg clean; then
    clean
fi

# Begin the actual script run
query_device    # Determine some basic information about the device that will be built on
prepare_device

# Install System dependencies and libraries needed to build Rapids libraries
if [ "$SKIP_DEPS" == "OFF" ]; then
    install_dependencies
else
    echo "Skipping dependencies installation"
fi

# Configure build tools and checkout code unless disabled
if [ "$SKIP_PREP_ENV" == "OFF" ]; then
    prepare_build_env
else
    echo "Skipping preparing environment and codebase"
fi

# Builds the desired libraries based on user supplied flags
build

# Print the total build time if not disabled
if [ "$SILENT_TIMES" == "OFF" ]; then
    ENDTIME=$(date +%s)
    echo "RapidsAI CUDF Install took: $(($ENDTIME - $GLOBALTIME)) seconds to complete"
fi