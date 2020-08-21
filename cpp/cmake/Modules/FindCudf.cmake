# - Find cuDF (cudf/types.hpp, libcudf.so)
# This module defines
#  CUDF_FOUND, whether cuDF has been found
#  CUDF_FULL_SO_VERSION, full shared object version of found cuDF "200.0.0"
#  CUDF_INCLUDE_DIR, directory containing headers
#  CUDF_LIB_DIR, directory containing cuDF libraries
#  CUDF_VERSION, version of found cuDF
#  CUDF_VERSION_MAJOR, major version of found cuDF
#  CUDF_VERSION_MINOR, minor version of found cuDF
#  CUDF_VERSION_PATCH, patch version of found cuDF

if(DEFINED CUDF_FOUND)
  return()
endif()

include(FindPkgConfig)
include(FindPackageHandleStandardArgs)

set(CUDF_SEARCH_LIB_PATH_SUFFIXES)
if(CMAKE_LIBRARY_ARCHITECTURE)
  list(APPEND CUDF_SEARCH_LIB_PATH_SUFFIXES "lib/${CMAKE_LIBRARY_ARCHITECTURE}")
endif()
list(APPEND CUDF_SEARCH_LIB_PATH_SUFFIXES
            "lib64"
            "lib32"
            "lib"
            "bin")
set(CUDF_CONFIG_SUFFIXES
    "_RELEASE"
    "_RELWITHDEBINFO"
    "_MINSIZEREL"
    "_DEBUG"
    "")
if(CMAKE_BUILD_TYPE)
  string(TOUPPER ${CMAKE_BUILD_TYPE} CUDF_CONFIG_SUFFIX_PREFERRED)
  set(CUDF_CONFIG_SUFFIX_PREFERRED "_${CUDF_CONFIG_SUFFIX_PREFERRED}")
  list(INSERT CUDF_CONFIG_SUFFIXES 0 "${CUDF_CONFIG_SUFFIX_PREFERRED}")
endif()

# Internal macro only for cudf_find_package.
#
# Find package in HOME.
macro(cudf_find_package_home)
  find_path(${prefix}_include_dir "${header_path}"
            PATHS "${home}"
            PATH_SUFFIXES "include"
            NO_DEFAULT_PATH)
  set(include_dir "${${prefix}_include_dir}")
  set(${prefix}_INCLUDE_DIR "${include_dir}" PARENT_SCOPE)

  find_library(${prefix}_shared_lib
               NAMES "${shared_lib_name}"
               PATHS "${home}"
               PATH_SUFFIXES ${ARROW_SEARCH_LIB_PATH_SUFFIXES}
               NO_DEFAULT_PATH)

  set(shared_lib "${${prefix}_shared_lib}")
  set(${prefix}_SHARED_LIB "${shared_lib}" PARENT_SCOPE)
  if(shared_lib)
    add_library(${target_shared} SHARED IMPORTED)
    set_target_properties(${target_shared} PROPERTIES IMPORTED_LOCATION "${shared_lib}")
    if(include_dir)
      set_target_properties(${target_shared}
                            PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${include_dir}")
    endif()
    find_library(${prefix}_import_lib
                 NAMES "${import_lib_name}"
                 PATHS "${home}"
                 PATH_SUFFIXES ${ARROW_SEARCH_LIB_PATH_SUFFIXES}
                 NO_DEFAULT_PATH)
    set(import_lib "${${prefix}_import_lib}")
    set(${prefix}_IMPORT_LIB "${import_lib}" PARENT_SCOPE)
    if(import_lib)
      set_target_properties(${target_shared} PROPERTIES IMPORTED_IMPLIB "${import_lib}")
    endif()
  endif()

  find_library(${prefix}_static_lib
               NAMES "${static_lib_name}"
               PATHS "${home}"
               PATH_SUFFIXES ${ARROW_SEARCH_LIB_PATH_SUFFIXES}
               NO_DEFAULT_PATH)
  set(static_lib "${${prefix}_static_lib}")
  set(${prefix}_STATIC_LIB "${static_lib}" PARENT_SCOPE)
  if(static_lib)
    add_library(${target_static} STATIC IMPORTED)
    set_target_properties(${target_static} PROPERTIES IMPORTED_LOCATION "${static_lib}")
    if(include_dir)
      set_target_properties(${target_static}
                            PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${include_dir}")
    endif()
  endif()
endmacro()

# Internal macro only for arrow_find_package.
#
# Find package by CMake package configuration.
macro(arrow_find_package_cmake_package_configuration)
  find_package(${cmake_package_name} CONFIG)
  if(${cmake_package_name}_FOUND)
    set(${prefix}_USE_CMAKE_PACKAGE_CONFIG TRUE PARENT_SCOPE)
    if(TARGET ${target_shared})
      foreach(suffix ${ARROW_CONFIG_SUFFIXES})
        get_target_property(shared_lib ${target_shared} IMPORTED_LOCATION${suffix})
        if(shared_lib)
          # Remove shared library version:
          #   libarrow.so.100.0.0 -> libarrow.so
          # Because ARROW_HOME and pkg-config approaches don't add
          # shared library version.
          string(REGEX
                 REPLACE "(${CMAKE_SHARED_LIBRARY_SUFFIX})[.0-9]+$" "\\1" shared_lib
                         "${shared_lib}")
          set(${prefix}_SHARED_LIB "${shared_lib}" PARENT_SCOPE)
          break()
        endif()
      endforeach()
    endif()
    if(TARGET ${target_static})
      foreach(suffix ${ARROW_CONFIG_SUFFIXES})
        get_target_property(static_lib ${target_static} IMPORTED_LOCATION${suffix})
        if(static_lib)
          set(${prefix}_STATIC_LIB "${static_lib}" PARENT_SCOPE)
          break()
        endif()
      endforeach()
    endif()
  endif()
endmacro()

# Internal macro only for arrow_find_package.
#
# Find package by pkg-config.
macro(arrow_find_package_pkg_config)
  pkg_check_modules(${prefix}_PC ${pkg_config_name})
  if(${prefix}_PC_FOUND)
    set(${prefix}_USE_PKG_CONFIG TRUE PARENT_SCOPE)

    set(include_dir "${${prefix}_PC_INCLUDEDIR}")
    set(lib_dir "${${prefix}_PC_LIBDIR}")
    set(shared_lib_paths "${${prefix}_PC_LINK_LIBRARIES}")
    # Use the first shared library path as the IMPORTED_LOCATION
    # for ${target_shared}. This assumes that the first shared library
    # path is the shared library path for this module.
    list(GET shared_lib_paths 0 first_shared_lib_path)
    # Use the rest shared library paths as the INTERFACE_LINK_LIBRARIES
    # for ${target_shared}. This assumes that the rest shared library
    # paths are dependency library paths for this module.
    list(LENGTH shared_lib_paths n_shared_lib_paths)
    if(n_shared_lib_paths LESS_EQUAL 1)
      set(rest_shared_lib_paths)
    else()
      list(SUBLIST
           shared_lib_paths
           1
           -1
           rest_shared_lib_paths)
    endif()

    set(${prefix}_VERSION "${${prefix}_PC_VERSION}" PARENT_SCOPE)
    set(${prefix}_INCLUDE_DIR "${include_dir}" PARENT_SCOPE)
    set(${prefix}_SHARED_LIB "${first_shared_lib_path}" PARENT_SCOPE)

    add_library(${target_shared} SHARED IMPORTED)
    set_target_properties(${target_shared}
                          PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
                                     "${include_dir}"
                                     INTERFACE_LINK_LIBRARIES
                                     "${rest_shared_lib_paths}"
                                     IMPORTED_LOCATION
                                     "${first_shared_lib_path}")
    get_target_property(shared_lib ${target_shared} IMPORTED_LOCATION)

    find_library(${prefix}_static_lib
                 NAMES "${static_lib_name}"
                 PATHS "${lib_dir}"
                 NO_DEFAULT_PATH)
    set(static_lib "${${prefix}_static_lib}")
    set(${prefix}_STATIC_LIB "${static_lib}" PARENT_SCOPE)
    if(static_lib)
      add_library(${target_static} STATIC IMPORTED)
      set_target_properties(${target_static}
                            PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${include_dir}"
                                       IMPORTED_LOCATION "${static_lib}")
    endif()
  endif()
endmacro()

function(arrow_find_package
         prefix
         home
         base_name
         header_path
         cmake_package_name
         pkg_config_name)
  arrow_build_shared_library_name(shared_lib_name ${base_name})
  arrow_build_import_library_name(import_lib_name ${base_name})
  arrow_build_static_library_name(static_lib_name ${base_name})

  set(target_shared ${base_name}_shared)
  set(target_static ${base_name}_static)

  if(home)
    arrow_find_package_home()
    set(${prefix}_FIND_APPROACH "HOME: ${home}" PARENT_SCOPE)
  else()
    arrow_find_package_cmake_package_configuration()
    if(${cmake_package_name}_FOUND)
      set(${prefix}_FIND_APPROACH
          "CMake package configuration: ${cmake_package_name}"
          PARENT_SCOPE)
    else()
      arrow_find_package_pkg_config()
      set(${prefix}_FIND_APPROACH "pkg-config: ${pkg_config_name}" PARENT_SCOPE)
    endif()
  endif()

  if(NOT include_dir)
    if(TARGET ${target_shared})
      get_target_property(include_dir ${target_shared} INTERFACE_INCLUDE_DIRECTORIES)
    elseif(TARGET ${target_static})
      get_target_property(include_dir ${target_static} INTERFACE_INCLUDE_DIRECTORIES)
    endif()
  endif()
  if(include_dir)
    set(${prefix}_INCLUDE_DIR "${include_dir}" PARENT_SCOPE)
  endif()

  if(shared_lib)
    get_filename_component(lib_dir "${shared_lib}" DIRECTORY)
  elseif(static_lib)
    get_filename_component(lib_dir "${static_lib}" DIRECTORY)
  else()
    set(lib_dir NOTFOUND)
  endif()
  set(${prefix}_LIB_DIR "${lib_dir}" PARENT_SCOPE)
  # For backward compatibility
  set(${prefix}_LIBS "${lib_dir}" PARENT_SCOPE)
endfunction()

if(NOT "$ENV{ARROW_HOME}" STREQUAL "")
  file(TO_CMAKE_PATH "$ENV{ARROW_HOME}" ARROW_HOME)
endif()
arrow_find_package(ARROW
                   "${ARROW_HOME}"
                   arrow
                   arrow/api.h
                   Arrow
                   arrow)

if(ARROW_HOME)
  if(ARROW_INCLUDE_DIR)
    file(READ "${ARROW_INCLUDE_DIR}/arrow/util/config.h" ARROW_CONFIG_H_CONTENT)
    arrow_extract_macro_value(ARROW_VERSION_MAJOR "ARROW_VERSION_MAJOR"
                              "${ARROW_CONFIG_H_CONTENT}")
    arrow_extract_macro_value(ARROW_VERSION_MINOR "ARROW_VERSION_MINOR"
                              "${ARROW_CONFIG_H_CONTENT}")
    arrow_extract_macro_value(ARROW_VERSION_PATCH "ARROW_VERSION_PATCH"
                              "${ARROW_CONFIG_H_CONTENT}")
    if("${ARROW_VERSION_MAJOR}" STREQUAL ""
       OR "${ARROW_VERSION_MINOR}" STREQUAL ""
       OR "${ARROW_VERSION_PATCH}" STREQUAL "")
      set(ARROW_VERSION "0.0.0")
    else()
      set(ARROW_VERSION
          "${ARROW_VERSION_MAJOR}.${ARROW_VERSION_MINOR}.${ARROW_VERSION_PATCH}")
    endif()

    arrow_extract_macro_value(ARROW_SO_VERSION_QUOTED "ARROW_SO_VERSION"
                              "${ARROW_CONFIG_H_CONTENT}")
    string(REGEX REPLACE "^\"(.+)\"$" "\\1" ARROW_SO_VERSION "${ARROW_SO_VERSION_QUOTED}")
    arrow_extract_macro_value(ARROW_FULL_SO_VERSION_QUOTED "ARROW_FULL_SO_VERSION"
                              "${ARROW_CONFIG_H_CONTENT}")
    string(REGEX
           REPLACE "^\"(.+)\"$" "\\1" ARROW_FULL_SO_VERSION
                   "${ARROW_FULL_SO_VERSION_QUOTED}")
  endif()
else()
  if(ARROW_USE_CMAKE_PACKAGE_CONFIG)
    find_package(Arrow CONFIG)
  elseif(ARROW_USE_PKG_CONFIG)
    pkg_get_variable(ARROW_SO_VERSION arrow so_version)
    pkg_get_variable(ARROW_FULL_SO_VERSION arrow full_so_version)
  endif()
endif()

set(ARROW_ABI_VERSION ${ARROW_SO_VERSION})

mark_as_advanced(ARROW_ABI_VERSION
                 ARROW_CONFIG_SUFFIXES
                 ARROW_FULL_SO_VERSION
                 ARROW_IMPORT_LIB
                 ARROW_INCLUDE_DIR
                 ARROW_LIBS
                 ARROW_LIB_DIR
                 ARROW_SEARCH_LIB_PATH_SUFFIXES
                 ARROW_SHARED_IMP_LIB
                 ARROW_SHARED_LIB
                 ARROW_SO_VERSION
                 ARROW_STATIC_LIB
                 ARROW_VERSION
                 ARROW_VERSION_MAJOR
                 ARROW_VERSION_MINOR
                 ARROW_VERSION_PATCH)

find_package_handle_standard_args(Arrow REQUIRED_VARS
                                  # The first required variable is shown
                                  # in the found message. So this list is
                                  # not sorted alphabetically.
                                  ARROW_INCLUDE_DIR
                                  ARROW_LIB_DIR
                                  ARROW_FULL_SO_VERSION
                                  ARROW_SO_VERSION
                                  VERSION_VAR
                                  ARROW_VERSION)
set(CUDF_FOUND ${Cudf_FOUND})

if(CUDF_FOUND AND NOT Cudf_FIND_QUIETLY)
  message(STATUS "cuDF version: ${CUDF_VERSION} (${CUDF_FIND_APPROACH})")
  message(STATUS "cuDF full SO version: ${CUDF_FULL_SO_VERSION}")
  message(STATUS "cuDF core shared library: ${CUDF_SHARED_LIB}")
endif()
