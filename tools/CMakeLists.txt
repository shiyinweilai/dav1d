##
## Copyright(C) 2018 - 2020 Tencent.
##
## All Rights Reserved.
##

# executable
set(DAV1D_APP_NAME dav1d)
add_executable(${DAV1D_APP_NAME} "")
if (NOT WIN32)
  add_definitions(-std=c99)
endif()
set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT "dav1d")
# set c++11
# add_definitions(-std=c++11)
# target_compile_features(${DAV1D_APP_NAME} PRIVATE cxx_constexpr)

set(DAV1D_SOURCES ${CMAKE_CURRENT_LIST_DIR}/dav1d.c
    ${CMAKE_CURRENT_LIST_DIR}/dav1d_cli_parse.c
    ${CMAKE_CURRENT_LIST_DIR}/input/annexb.c
    ${CMAKE_CURRENT_LIST_DIR}/input/input.c
    ${CMAKE_CURRENT_LIST_DIR}/input/ivf.c
    ${CMAKE_CURRENT_LIST_DIR}/input/section5.c
    ${CMAKE_CURRENT_LIST_DIR}/output/md5.c
    ${CMAKE_CURRENT_LIST_DIR}/output/null.c
    ${CMAKE_CURRENT_LIST_DIR}/output/output.c
    ${CMAKE_CURRENT_LIST_DIR}/output/y4m2.c
    ${CMAKE_CURRENT_LIST_DIR}/output/yuv.c)
	
if (WIN32)
  set(DAV1D_SOURCES ${DAV1D_SOURCES} ${CMAKE_SOURCE_DIR}/tools/compat/getopt.c)
endif()

target_sources(${DAV1D_APP_NAME}
  PRIVATE ${DAV1D_SOURCES}
)

target_include_directories(${DAV1D_APP_NAME}
  PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}/inc
  ${PROJECT_SOURCE_DIR}/include

)

# compile setting
if (WIN32)
  if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "aarch64")
    thumb_log("-- tools: arm64 on windows" 33)
  elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv7")
    thumb_log("-- tools: armv7 on windows" 33)
  elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_64")
    thumb_log("-- tools: x86_64 on windows" 33)
    set(CMAKE_C_FLAGS "-EHsc -D_CRT_SECURE_NO_WARNINGS -DWIN32 -DNDEBUG")
    set(CMAKE_CXX_FLAGS "-EHsc -D_CRT_SECURE_NO_WARNINGS -DWIN32  -DNDEBUG")
  elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_32")
    thumb_log("-- tools: x86_32 on windows" 33)
    set(CMAKE_C_FLAGS "-EHsc -D_CRT_SECURE_NO_WARNINGS -DWIN32 -DNDEBUG")
    set(CMAKE_CXX_FLAGS "-EHsc -D_CRT_SECURE_NO_WARNINGS -DWIN32  -DNDEBUG")
  endif()
  include_directories(${PROJECT_SOURCE_DIR}/tools) # whatever inclue
  include_directories(${PROJECT_SOURCE_DIR}/include/dav1d) # whatever inclue
elseif (APPLE)
  include_directories(${PROJECT_SOURCE_DIR}/build/apple/aarch64) # whatever inclue
  set(CMAKE_XCODE_ATTRIBUTE_CMAKE_OSX_DEPLOYMENT_TARGET "10.8" CACHE STRING "Deployment target for osx" FORCE)
  set(CMAKE_OSX_DEPLOYMENT_TARGET "10.8" CACHE STRING "Deployment target for osx" FORCE)
  set(CMAKE_C_FLAGS "-m64 -stdlib=libc++")
  set(CMAKE_CXX_FLAGS "-m64 -stdlib=libc++")
elseif (ANDROID)
  include_directories(${PROJECT_SOURCE_DIR}/build/android/arm64-v8a)
  add_compile_definitions(NDEBUG)
elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
  add_compile_definitions(NDEBUG)
  if (CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64")
    include_directories(${PROJECT_SOURCE_DIR}/build/linux/arm64)
    
    add_compile_definitions(AARCH64=1 _POSIX_C_SOURCE=200809L)

    set (CMAKE_C_COMPILER "aarch64-linux-gnu-gcc")
    set (CMAKE_CXX_COMPILER "aarch64-linux-gnu-g++")
    set (CMAKE_AR "aarch64-linux-gnu-ar")
  elseif (CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_32")
    include_directories(${PROJECT_SOURCE_DIR}/build/linux/x86_32)
    set(CMAKE_EXE_LINKER_FLAGS "-m32 -W -z text")
    target_compile_options(${DAV1D_APP_NAME} PRIVATE -m32 -D__STDC_FORMAT_MACROS -D_GNU_SOURCE)
  else()
    include_directories(${PROJECT_SOURCE_DIR}/build/linux/x86_64)
    target_compile_options(${DAV1D_APP_NAME} PRIVATE -m64 -D__STDC_FORMAT_MACROS -D_POSIX_C_SOURCE=199309L -D_GNU_SOURCE)
  endif()
endif()

# link setting
if (WIN32)
  target_link_libraries(${DAV1D_APP_NAME} ${DAV1D_LIB_STATIC})
elseif (APPLE)
  target_link_libraries(${DAV1D_APP_NAME} ${DAV1D_LIB_STATIC} pthread dl m)
elseif (ANDROID)
  target_link_libraries(${DAV1D_APP_NAME} ${DAV1D_LIB_STATIC} dl m)
elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_link_libraries(${DAV1D_APP_NAME} ${DAV1D_LIB_STATIC} pthread dl m rt)
endif()


