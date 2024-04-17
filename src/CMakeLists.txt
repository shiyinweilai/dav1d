##
## Copyright(C) 2018 - 2020 Tencent.
##
## All Rights Reserved.
##

# For M1 Silicon Chip
option(MACOS_ARM64 OFF)
option(MAC_CATALYST OFF)
option(DYNAMIC_LIB "enable dynamic libs" OFF)

if ((CMAKE_SYSTEM_NAME STREQUAL "Linux") OR ANDROID)
  set(DYNAMIC_LIB ON)
endif()

# bitdepths
option(bitdepth_8 "Enable specified bitdepths" ON)
if (WIN32 AND NOT(CMAKE_CL_64))
  option(bitdepth_16 "Enable specified bitdepths" ON)
else()
  option(bitdepth_16 "Enable specified bitdepths" ON)
endif()
option(bitdepth_16 "Enable specified bitdepths" ON)

# enable_avx512
option(enable_avx512 "Build AVX-512 asm files, requires nasm 2.14" OFF)

# compatibility
set(bitdepths "")

if(bitdepth_8)
    list(APPEND bitdepths "8")
endif()

if(bitdepth_16)
    list(APPEND bitdepths "16")
endif()

foreach(BITS IN LISTS bitdepths)
    set(CONFIG_${BITS}BPC 1)
endforeach()

if(ENABLE_ASM)
  set(HAVE_ASM 1)
endif()

# LIBDAV1D_SOURCES 
include(${PROJECT_SOURCE_DIR}/build/file_manager.cmake)
thumb_log("-- asm sources files have:" 35)
message (STATUS "${LIBDAV1D_SOURCES_ASM}")
thumb_log("-- sources files have:" 35)
message (STATUS "${LIBDAV1D_SOURCES}")
# library

if (NOT WIN32)
  if(DYNAMIC_LIB)
    add_library(${DAV1D_LIB_DYNAMIC} SHARED ${LIBDAV1D_SOURCES} ${LIBDAV1D_SOURCES_ASM} ${LIBDAV1D_ENTRYPOINT_SOURCES})
  endif()
endif()
add_library(${DAV1D_LIB_STATIC} STATIC ${LIBDAV1D_SOURCES} ${LIBDAV1D_SOURCES_ASM} ${LIBDAV1D_ENTRYPOINT_SOURCES})

if (WIN32)
  SET_TARGET_PROPERTIES (${DAV1D_LIB_STATIC} PROPERTIES OUTPUT_NAME "libdav1d")
elseif (APPLE)
  if(DYNAMIC_LIB)
    SET_TARGET_PROPERTIES (${DAV1D_LIB_DYNAMIC} PROPERTIES OUTPUT_NAME "libdav1d")
  endif()
  SET_TARGET_PROPERTIES (${DAV1D_LIB_STATIC} PROPERTIES OUTPUT_NAME "dav1d")
elseif (ANDROID OR CMAKE_SYSTEM_NAME STREQUAL "Linux")
  SET_TARGET_PROPERTIES (${DAV1D_LIB_DYNAMIC} PROPERTIES OUTPUT_NAME "dav1d")
  SET_TARGET_PROPERTIES (${DAV1D_LIB_STATIC} PROPERTIES OUTPUT_NAME "dav1d")
endif()

if (NOT WIN32)
  # set c99
  add_definitions(-std=c99)
  # target_compile_features(${DAV1D_LIB_DYNAMIC} PRIVATE cxx_constexpr)
  # target_compile_features(${DAV1D_LIB_STATIC} PRIVATE cxx_constexpr)
endif()

include_directories(${CMAKE_CURRENT_LIST_DIR})

# compile setting
if (WIN32)
  include(${PROJECT_SOURCE_DIR}/build/windows/dav1d_windows.cmake)
elseif (APPLE)
  if (IOS AND NOT VISIONOS)
    include(${PROJECT_SOURCE_DIR}/build/apple/dav1d_ios.cmake)
  elseif (VISIONOS)
    include(${PROJECT_SOURCE_DIR}/build/apple/dav1d_visionos.cmake)
  else() # mac os arm64 x86_64
    include(${PROJECT_SOURCE_DIR}/build/apple/dav1d_macos.cmake)
  endif()
elseif (ANDROID)
  include(${PROJECT_SOURCE_DIR}/build/android/dav1d_android.cmake)
elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
  include(${PROJECT_SOURCE_DIR}/build/linux/dav1d_linux.cmake)
endif()

foreach(BITS IN LISTS bitdepths)
    add_library(dav1d_bitdepth_${BITS} STATIC ${LIBDAV1D_TMPL_SOURCES})
    target_compile_definitions(dav1d_bitdepth_${BITS} PRIVATE BITDEPTH=${BITS})
    target_link_libraries(${DAV1D_LIB_STATIC} dav1d_bitdepth_${BITS})
    if (NOT WIN32)
      if(DYNAMIC_LIB)
        target_link_libraries(${DAV1D_LIB_DYNAMIC} dav1d_bitdepth_${BITS})
      endif()
	  endif()
endforeach()