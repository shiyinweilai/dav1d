##
## Copyright(C) 2018 - 2020 Tencent.
##
## All Rights Reserved.
##

cmake_minimum_required(VERSION 3.9)

project(dav1d LANGUAGES C)

set(DAV1D_MAJOR_VERSION 1)
set(DAV1D_MINOR_VERSION 3)
set(DAV1D_PATCH_VERSION 7)
set(DAV1D_VERSION ${DAV1D_MAJOR_VERSION}.${DAV1D_MINOR_VERSION}.${DAV1D_PATCH_VERSION})

set(DAV1D_API_VERSION_MAJOR 6)
set(DAV1D_API_VERSION_MINOR 0)
set(DAV1D_API_VERSION_PATCH 0)

#@rbyang todo
option(BUILD_SHARED_LIBS "Build using shared libraries" OFF)

function(thumb_log message color_code)
    string(ASCII 27 Esc)
    set(ColorReset "${Esc}[0m")
    set(ColorCode "${Esc}[${color_code}m")
    message("${ColorCode}${message}${ColorReset}")
endfunction()

configure_file (
    "${CMAKE_SOURCE_DIR}/include/vcs_version.h.in"
    "${CMAKE_SOURCE_DIR}/build/include/vcs_version.h"
)
configure_file (
    "${CMAKE_SOURCE_DIR}/include/dav1d/version.h.in"
    "${CMAKE_SOURCE_DIR}/build/include/dav1d/version.h"
)

# Disable in-source builds to prevent source tree corruption.
if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
  message(FATAL_ERROR
          "FATAL: In-source builds are not allowed.
          You should create a separate directory for build files.")
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(CMAKE_SUPPRESS_REGENERATION TRUE)

# set default CMAKE_BUILD_TYPE to Release if not set
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build,
      options are: Debug Release RelWithDebInfo MinSizeRel." FORCE )
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

include_directories("${CMAKE_SOURCE_DIR}")
include_directories("${CMAKE_SOURCE_DIR}/include")
include_directories("${CMAKE_SOURCE_DIR}/build/include")
include_directories("${CMAKE_SOURCE_DIR}/build/include/dav1d")

# set verbose compile options
set(CMAKE_VERBOSE_MAKEFILE ON)

# use folders in IDEs for projects (e.g. lib sample app test)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)

# set compiler options
add_compile_definitions(DAV1D_VERSION="${DAV1D_VERSION}")
add_compile_definitions(DAV1D_VERSION_NUM=${DAV1D_MAJOR_VERSION}\,\ ${DAV1D_MINOR_VERSION}\,\ ${DAV1D_PATCH_VERSION})

if (ANDROID)
  set(CMAKE_ANDROID_ARCH_ABI arm64-v8a)
  set(CMAKE_ANDROID_STL_TYPE gnustl_static)
endif()



if (MSVC)
  # add windows specific directories
  if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "aarch64")
    include_directories("${CMAKE_SOURCE_DIR}/build/windows/arm64")
  elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv7")
    include_directories("${CMAKE_SOURCE_DIR}/build/windows/armv7")
  elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_64")
    include_directories("${CMAKE_SOURCE_DIR}/build/windows/win64")
  elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_32")
    include_directories("${CMAKE_SOURCE_DIR}/build/windows/win32")
  endif()
  
  include_directories("${CMAKE_SOURCE_DIR}/include/compat")
  include_directories("${CMAKE_SOURCE_DIR}/include/compat/msvc")
  # warning level 4 and all warnings as errors
  # add_compile_options(/W4 /WX)
  add_compile_options(/W4 /WX- /Ob2 /Ot /GL /GF /MT /GS- /Gy /MP)
elseif (CMAKE_C_COMPILER_ID MATCHES GNU)
  set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG")
  add_link_options(-O3)
  if (USE_ASAN)
    add_compile_options(-fsanitize=address)
    link_libraries(-lasan)
  endif()
elseif (ANDROID)
  set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG")
  add_link_options(-O3)
  if (USE_ASAN)
    add_compile_options(-fsanitize=address)
    link_libraries(-lasan)
  endif()
elseif (CMAKE_C_COMPILER_ID MATCHES Clang)
  set(CMAKE_MODULE_LINKER_FLAGS "-rpath @executable_path/Frameworks -rpath @loader_path/Frameworks")
  set(CMAKE_SHARED_LINKER_FLAGS "-rpath @executable_path/Frameworks -rpath @loader_path/Frameworks")
  set(CMAKE_SKIP_BUILD_RPATH FALSE)
  set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG -Werror")
  add_link_options(-O3)
endif()
# library
if (NOT MSVC)
  set(DAV1D_LIB_DYNAMIC "libdav1d_dynamic")
endif()
set(DAV1D_LIB_STATIC "libdav1d_static")

add_subdirectory("src")
add_subdirectory("tools")
