#=============================================================================
# Copyright (c) 2018-2020, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================
cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(CUDA_S3 VERSION 0.19.0 LANGUAGES C CXX)

#################################################################################################
# - CUDA architectures

# If CMAKE_CUDA_ARCHITECTURES is not defined, build for all supported architectures. If
# CMAKE_CUDA_ARCHITECTURES is set to an empty string (""), build for only the current
# architecture. If `CMAKE_CUDA_ARCHITECTURES` is specified by the user, use user setting.

# This needs to be run before enabling the CUDA language due to the default initialization behavior
# of CMAKE_CUDA_ARCHITECTURES, https://gitlab.kitware.com/cmake/cmake/-/issues/21302
if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
  set(CUDF_BUILD_FOR_ALL_ARCHS TRUE)
elseif(CMAKE_CUDA_ARCHITECTURES STREQUAL "")
  unset(CMAKE_CUDA_ARCHITECTURES CACHE)
  set(CUDF_BUILD_FOR_DETECTED_ARCHS TRUE)
endif()

###################################################################################################
# - Build options

option(CUDF_USE_ARROW_STATIC "Build static arrow library" OFF)
option(CUDF_S3_BUILD_TESTS "Build tests for libcudf_s3" ON)
option(CUDF_S3_BUILD_BENCHMARKS "Build benchmarks for libcudf_s3" OFF)

message(VERBOSE "CUDF_S3: Build gtests: ${CUDF_S3_BUILD_TESTS}")
message(VERBOSE "CUDF_S3: Build benchmarks: ${CUDF_S3_BUILD_BENCHMARKS}")
message(VERBOSE "CUDF_S3: Use Arrow Static: ${CUDF_USE_ARROW_STATIC}")

###################################################################################################
# - compiler options ------------------------------------------------------------------------------

# * find CUDAToolkit package
# * determine GPU architectures
# * enable the CMake CUDA language
# * set other CUDA compilation flags
include(cmake/Modules/ConfigureCUDA.cmake)

###################################################################################################
# - Dependencies

# CPM
include(cmake/thirdparty/CUDF_S3_GetCPM.cmake)

# libcudf
include(cmake/thirdparty/CUDF_S3_GetCUDF.cmake)

# # GTests if enabled
if (CUDF_KAFKA_BUILD_TESTS)
    # include CTest module -- automatically calls enable_testing()
    include(CTest)
    add_subdirectory(tests)
endif()

###################################################################################################
# - include paths ---------------------------------------------------------------------------------

include_directories("${CMAKE_BINARY_DIR}/include"
                    "${CMAKE_SOURCE_DIR}/include"
                    "${CMAKE_SOURCE_DIR}/src")

###################################################################################################
# - library paths ---------------------------------------------------------------------------------

link_directories("${CMAKE_CUDA_IMPLICIT_LINK_DIRECTORIES}" # CMAKE_CUDA_IMPLICIT_LINK_DIRECTORIES is an undocumented/unsupported variable containing the link directories for nvcc
                 "${CMAKE_BINARY_DIR}/lib"
                 "${CMAKE_BINARY_DIR}")

###################################################################################################
# - library target --------------------------------------------------------------------------------

add_library(cudf_s3 SHARED
    src/s3_arrow_datasource.cpp
)

###################################################################################################
# - cudf_s3 Install ----------------------------------------------------------------------------
target_link_libraries(cudf_s3 cudf::cudf)

install(TARGETS cudf_s3
        DESTINATION lib)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include
        DESTINATION include)