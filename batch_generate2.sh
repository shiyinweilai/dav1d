#!/bin/bash

###############################################################################
# Copyright(C) 2021 - 2022 Tencent.
#
# All Rights Reserved.
###############################################################################

# print error info
print_error() {
    # echo -e " \033[31m[error] ${1}\033[0m"
    echo -e " \033[1;41;37m[error] ${1}\033[0m"

}

# print successful info
# show_result(){
#     echo -e " \033[32m[success] ${1}\033[0m"
# }
show_result() {
    if [ $? != 0 ]; then
        echo -e " \033[31m [failed!] $1\033[0m"
        exit 1
    else
        echo -e " \033[32m [success] $1\033[0m"
    fi
}
# print warning info
print_warning() {
    echo -e " \033[33m [warning] ${1}\033[0m"
}

# print attention info
print_info() {
    echo -e " \033[35m [attention] ${1}\033[0m"
}

version_lt() {
    test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"
}

setEnv() {
    CMAKE_VERSOIN_MIN=3.12
    CMAKE_VERSOIN=$(cmake --version 2>&1 | sed '1!d' | sed -e 's/"//g' | awk '{print $3}')
    if version_lt ${CMAKE_VERSOIN} ${CMAKE_VERSOIN_MIN}; then
        print_error "CMAKE_VERSOIN: ${CMAKE_VERSOIN} is too old!"
        echo "need higher version! min required: ${CMAKE_VERSOIN_MIN}"
        exit -1
    else
        echo $(cmake --version)
    fi
}

check_nasm() {
    NASM_VERSION_MIN=2.13
    CMAKE_VERSOIN=$(nasm --version 2>&1 | sed '1!d' | sed -e 's/"//g' | awk '{print $3}')
    if version_lt ${NASM_VERSION} ${NASM_VERSION_MIN}; then
        print_error "CMAKE_VERSOIN: ${NASM_VERSION} is too old!"
        echo "need higher version! min required: ${NASM_VERSION}"
        exit -1
    else
        echo $(cmake --version)
    fi
}

# Function init
#
# For this function you can call it to clear old project data
# Like old libdav1d and dectect some config
#
# return null
#
init() {
    echo ===============================================================================================
    print_info "start building on ${1} platform with ${2} architecture"
    if [ ${platform} == "Windows" ]; then
        rm -rf ${WORKSPACE}/${platform}/${arg}/*
        rm -rf ${WORKSPACE}/../bin/Release/*
        rm -rf ${root_path}/libdav1d/${1}/${2}
    else
        build_out_dir=${WORKSPACE}/${1}/${2}
        rm -rf ${build_out_dir}
        rm -rf ${WORKSPACE}/*${2}.log
        rm -rf ${WORKSPACE}/${platform}/${2}
        if [ -f"${root_path}/bin" ]; then
            rm -rf ${root_path}/bin
            rm -rf ${root_path}/libdav1d/${1}/${2}
            show_result "old product have been deleted!"
        fi
    fi
}

# Function store
#
# For this function you can call it to generate libdav1d specified architechture
# And arranged by different platform
#
# return null
#
store() {
    if [ ${platform} == "Windows" ]; then
        mkdir -p ${root_path}/libdav1d/${1}/${2}/lib
        mkdir ${root_path}/libdav1d/${1}/${2}/include
        cp ${root_path}/bin/Release/* ${root_path}/libdav1d/${1}/${2}/lib/
        cp -r ${root_path}/include/dav1d ${root_path}/libdav1d/${1}/${2}/include/dav1d
        cp ${root_path}/build/include/dav1d/version.h ${root_path}/libdav1d/${1}/${2}/include/dav1d
        rm -rf ${root_path}/libdav1d/${1}/${2}/include/dav1d/version.h.in
    elif [ ${platform} == "Linux" ] || [ ${platform} == "Android" ]; then
        if [ -f "${root_path}/bin/dav1d" ]; then
            show_result "dav1d generated!"
        else
            print_warning "dav1d failed!"
        fi
        if [ -f "${root_path}/bin/libdav1d.a" ]; then
            show_result "got libdav1d.a"
            echo ===============================================================================================
            echo ""
            mkdir -p ${root_path}/libdav1d/${1}/${2}/lib
            mkdir ${root_path}/libdav1d/${1}/${2}/include
            cp ${root_path}/bin/libdav1d.a ${root_path}/libdav1d/${1}/${2}/lib/libdav1d.a
            # cp ${root_path}/bin/libdav1d.so ${root_path}/libdav1d/${platform}/${arg}/lib/libdav1d.so
            cp -r ${root_path}/include/dav1d ${root_path}/libdav1d/${1}/${2}/include/dav1d
            cp ${root_path}/build/include/dav1d/version.h ${root_path}/libdav1d/${1}/${2}/include/dav1d
            rm -rf ${root_path}/libdav1d/${1}/${2}/include/dav1d/version.h.in
        else
            print_error "no libdav1d.a"
            echo ===============================================================================================
            echo ""
        fi
        if [ "${cp_exe}" == "y" ]; then
            cp ${root_path}/bin/dav1d ${root_path}/libdav1d/${1}/${2}/lib/dav1d
        fi
        if [ "${cp_dynamic}" == "y" ]; then
            cp ${root_path}/bin/libdav1d.so ${root_path}/libdav1d/${1}/${2}/lib
        fi
    else
        lib_out=${1}
        if [ -f "${root_path}/bin/Release/dav1d" ]; then
            show_result "dav1d generated!"
        else
            print_warning "dav1d failed!"
        fi

        if [ -f "${root_path}/bin/Release/libdav1d.a" ]; then
            show_result "got libdav1d.a"
            echo ===============================================================================================
            echo ""
            mkdir -p ${root_path}/libdav1d/${1}/${2}/lib
            mkdir ${root_path}/libdav1d/${1}/${2}/include
            cp ${root_path}/bin/Release/libdav1d.a ${root_path}/libdav1d/${1}/${2}/lib/libdav1d.a
            cp -r ${root_path}/include/dav1d ${root_path}/libdav1d/${1}/${2}/include
            cp ${root_path}/build/include/dav1d/version.h ${root_path}/libdav1d/${1}/${2}/include/dav1d
            rm -rf ${root_path}/libdav1d/${1}/${2}/include/dav1d/version.h.in
        else
            print_error "no libdav1d.a"
            echo ===============================================================================================
            echo ""
        fi
        if [ "${cp_exe}" == "y" ]; then
            cp ${root_path}/bin/Release/dav1d ${root_path}/libdav1d/${1}/${2}/lib
        fi
        if [ "${cp_dynamic}" == "y" ]; then
            cp ${root_path}/bin/libdav1d.dylib ${root_path}/libdav1d/${platform}/${arg}/lib
        fi
    fi

    print_info "all libs/exe will be written in ${root_path}/libdav1d/"
}

# Function build_Darwin
#
# For this function you can call it to generate libdav1d for x86_64 x86_32 arm64 architechture
# And arranged by MacOS platform
#
# return null
#
# 编译Windows库
build_Windows() {
    platform="Windows"
    # ARGH="x86_64 x86_32 arm64 armv7"
    ARGH="x86_64 x86_32 arm64 "
    for arg in ${ARGH}; do
        cd ${root_path}/
        if [ $? == 0 ]; then
            init ${platform} ${arg}
            if [ $arg == "arm64" ]; then
                ${root_path}/generate_project.sh -asm ${ASM} -s ${platform} -a ${arg}
                cd ${WORKSPACE}/${platform}/${arg}
                cmake --build . --config Release --clean-first
            else
                ${root_path}/generate_project.sh -asm ${ASM} -s ${platform} -a ${arg}
                cd ${WORKSPACE}/${platform}/${arg}
                cmake --build . --config Release --clean-first
            fi
            store ${platform} ${arg}
        fi
    done
}

# Function build_Darwin
#
# For this function you can call it to generate libdav1d for x86_64 architechture
# And arranged by MacOS platform
#
# return null
#
# 编译macoxs库
build_Darwin() {
    platform="Darwin"
    # ARGH="x86_64 arm64 mac_catalyst_x86_64"
    ARGH="x86_64 arm64"
    for arg in ${ARGH}; do
        cd ${root_path}/
        if [ $? == 0 ]; then
            if [ $arg == "arm64" ]; then
                platform=macosx
                init Darwin ${arg}
                ${root_path}/generate_project.sh -asm ${ASM} -s Darwin -a ${arg} 1>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
                cd ${WORKSPACE}/Darwin/${arg}
                xcodebuild -scheme ALL_BUILD -UseModernBuildSystem=0 -config Release -sdk macosx12.3 -arch arm64 1>>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
                store ${platform} ${arg}
            elif [ ${arg} == "mac_catalyst_x86_64" ]; then
                platform=ios
                init Darwin ${arg}
                ${root_path}/generate_project.sh -asm ${ASM} -s Darwin -a ${arg} 1>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
                # xcodebuild -configuration Release -destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' clean build SUPPORTS_MACCATALYST=YES BUILD_LIBRARIES_FOR_DISTRIBUTION=YES 1>>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
                cd ${WORKSPACE}/Darwin/${arg}

                xcodebuild -config Release -arch x86_64 -destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' OTHER_CFLAGS='-arch x86_64 -target x86_64-apple-ios13.1-macabi -mmacosx-version-min=10.8' OTHER_CPLUSPLUSFLAGS='-arch x86_64 -target x86_64-apple-ios13.1-macabi -mmacosx-version-min=10.8' OTHER_LDFLAGS='-arch x86_64 -target x86_64-apple-ios13.1-macabi -mmacosx-version-min=10.8' SUPPORTS_MACCATALYST=YES BUILD_LIBRARIES_FOR_DISTRIBUTION=YES 1>>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
                store ${platform} ${arg}
            else
                platform=macosx
                init Darwin ${arg}
                ${root_path}/generate_project.sh -asm ${ASM} -s Darwin -a ${arg} 1>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
                cd ${WORKSPACE}/Darwin/${arg}
                xcodebuild -scheme ALL_BUILD -UseModernBuildSystem=0 -config Release build 1>>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
                store ${platform} ${arg}
            fi
        fi
    done
}

# Function build_IOS
#
# For this function you can call it to generate libdav1d for arm64 arm64e armv7 armv7s architechture
# And arranged by iPhoneOS platform
#
# return null
#
# 编译iOS真机库
build_IOS() {
    platform="IOS"
    ARGH="arm64 arm64e armv7 armv7s"
    # ARGH="arm64"
    for arg in ${ARGH}; do
        cd ${root_path}/
        init ${platform} ${arg}
        ${root_path}/generate_project.sh -asm ${ASM} -s ${platform} -a ${arg} 1>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
        if [ $? == 0 ]; then
            cd ${WORKSPACE}/${platform}/${arg}
            xcodebuild -scheme libdav1d_static -UseModernBuildSystem=0 -config Release -destination generic/platform=iOS build 1>>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
            store "ios" ${arg}
        fi
    done
}

# Function build_IOS_SIMULATOR64
#
# For this function you can call it to generate libdav1d for x86_64 architechture
# And arranged by SIMULATOR platform
#
# return null
#
# 编译iOS模拟器库
build_IOS_SIMULATOR() {
    platform="IOS_SIMULATOR"
    ARGH="x86_64 arm64_simu i386"
    # ARGH="arm64_simu"
    for arg in ${ARGH}; do
        cd ${root_path}/
        init "ios" ${arg}
        ${root_path}/generate_project.sh -asm ${ASM} -s ${platform} -a $arg 1>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
        if [ $? == 0 ]; then
            cd ${WORKSPACE}/${platform}/${arg}
            if [ "${arg}" == "arm64_simu" ]; then
                xcodebuild -scheme libdav1d_static -UseModernBuildSystem=0 -config Release -sdk iphonesimulator -arch arm64 build 1>>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
            else
                xcodebuild -scheme libdav1d_static -UseModernBuildSystem=0 -config Release -sdk iphonesimulator -arch ${arg} build 1>>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
            fi
            store "ios" ${arg}
        fi
    done
}

build_VISIONOS() {
    platform="VISIONOS"
    ARGH="arm64 arm64e arm64_simu x86_64"
    # ARGH="arm64"
    for arg in ${ARGH}; do
        cd ${root_path}/
        init "visionos" ${arg}
        if [ "${arg}" == "arm64e" ]; then
            ${root_path}/generate_project.sh -asm 0 -s ${platform} -a $arg 1>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
        else
            ${root_path}/generate_project.sh -asm ${ASM} -s ${platform} -a $arg 1>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
        fi
        if [ $? == 0 ]; then
            cd ${WORKSPACE}/${platform}/${arg}
            if [ "${arg}" == "arm64" ] || [ "${arg}" == "arm64e" ]; then
                xcodebuild -scheme libdav1d_static -UseModernBuildSystem=0 -config Release -sdk xros -arch ${arg} build 1>>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
            else
                if [ "${arg}" == "arm64_simu" ]; then
                    xcodebuild -scheme libdav1d_static -UseModernBuildSystem=0 -config Release -sdk xrsimulator -arch arm64 build 1>>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
                else
                    xcodebuild -scheme libdav1d_static -UseModernBuildSystem=0 -config Release -sdk xrsimulator -arch ${arg} build 1>>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
                fi
            fi
            store "visionos" ${arg}
        fi
    done
}

# Function build_Linux
#
# For this function you can call it to generate libdav1d for x86_64 architechture
# And arranged by Linux platform
#
# return null
#
# 编译Linux平台库
build_Linux() {
    platform="Linux"
    if command -v aarch64-linux-gnu-gcc >/dev/null 2>&1; then
        ARGH="arm64 x86_64 x86_32"
    else
        ARGH="x86_64 x86_32"
    fi
    check_nasm
    for arg in ${ARGH}; do
        cd ${root_path}/
        init ${platform} ${arg}
        ${root_path}/generate_project.sh -asm ${ASM} -s ${platform} -a ${arg} 1>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
        if [ $? == 0 ]; then
            cd ${WORKSPACE}/${platform}/${arg}/Release
            make -j 32 1>>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
            store ${platform} ${arg}
        fi
    done
}

# Function build_Android
#
# For this function you can call it to generate libdav1d for arm64 armv7 x86_64 x86_32 architechture
# And arranged by Android platform
#
# return null
#
# 编译Android平台库
build_Android() {
    NDK_VERSION=$(echo ${ANDROID_NDK} | grep "android-ndk-r15c")
    if [ "${NDK_VERSION}" != "" ]; then
        print_warning "your ANDROID_NDK is ${ANDROID_NDK}"
    else
        print_error "NDK_VERSION unexpected, please download android-ndk-r15c from \n
        https://github.com/android/ndk/wiki/Unsupported-Downloads#r15c \n
        and set env of it with name of ANDROID_NDK"
    fi
    check_nasm
    platform="Android"
    lib_path=${WORKSPACE}../bin/libdav1d.a
    ARGH="arm64-v8a armeabi-v7a x86_64 x86"
    # ARGH="armeabi-v7a"
    for arg in ${ARGH}; do
        cd ${root_path}/
        init "android" ${arg}
        ${root_path}/generate_project.sh -asm ${ASM} -s ${platform} -a ${arg} 1>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
        if [ $? == 0 ]; then
            cd ${WORKSPACE}/${platform}/${arg}/Release
            make -j 32 1>>${WORKSPACE}/${platform}_${arg}.log 2>>${WORKSPACE}/${platform}_${arg}.log
            store "android" ${arg}
        fi
    done
    if [[ -d "${root_path}/libdav1d/android/armeabi" ]]; then
        rm -rf ${root_path}/libdav1d/android/armeabi
        cp -rf ${root_path}/libdav1d/android/armeabi-v7a ${root_path}/libdav1d/android/armeabi
    else
        cp -rf ${root_path}/libdav1d/android/armeabi-v7a ${root_path}/libdav1d/android/armeabi
    fi
    # rm -rf ${root_path}/libdav1d/android
    # mv ${root_path}/libdav1d/Android ${root_path}/libdav1d/android
    print_info "for armeabi arch, use armeabi-v7a so file directly, just copy to armeabi folder"
}

# Function print_usage
#
# For this function you can call it to get help
# And arranged by Android platform
#
# return null
#
print_usage() {
    print_info "====================================================================================================="
    echo " Usage:
    sh batch_generate.sh [< -asm (1 | 0)>  <-s (platform)>  <-ce (y | n)>  <-cp (y | n)>]"
    echo " Eg:
    cmd with \"sh batch_generate.sh -s 1\" will generate two libs with architecture x86_64 and arm64 on
    platform Darwin(macos)"
    echo " "
    echo " Params:"
    echo "   -s 1         platform on Darwin(macos)  with architecture x86_64 arm64(for M1 silicon chip)"
    echo "   -s 2         platform on IOS            with architecture arm64 arm64e armv7 armv7s"
    echo "   -s 3         platform on IOS_SIMULATOR  with architecture x86_64 i386 arm64_simu"
    echo "   -s 4         platform on VISIONOS       with architecture arm64 arm64e arm64_simu x86_64"
    echo "   -s 5         platform on Linux          with architecture x86_64 x86_32"
    echo "   -s 6         platform on Android        with architecture arm64-v8a armeabi-v7a armeabi x86_64 x86_32"
    echo "   -s 7         platform on Windows        with architecture x86_64 x86_32 arm64-v8a armv7"
    echo "   -ce y        copy exe to dst director"
    echo "   -cd y        copy dynamic lib to dst director"
    echo "   -asm 1/0     turn on/off asm"
    echo " "
    print_info "====================================================================================================="
    echo " "
}

# Function print_usage
#
# For this function you can call it to get started
#
# return null
#
launch() {
    show_result "Starting......"
    if [ "${PlatformIndex}" == "" ]; then
        print_usage
        show_result "input num (1 | 2 | 3 | 4 | 5 | 6) to specify platform you want to build on"
        read -p "select 1~6: " PlatformIndex
        case $PlatformIndex in
        1)
            build_Darwin
            ;;
        2)
            build_IOS
            ;;
        3)
            build_IOS_SIMULATOR
            ;;
        4)
            build_VISIONOS
            ;;
        5)
            build_Linux
            ;;
        6)
            build_Android
            ;;
        7)
            build_Windows
            ;;
        *)
            print_error "unsported platform!"
            exit -1
            ;;
        esac
        print_info "all libs will have been written into ${root_path}/libdav1d !"
    else
        case ${PlatformIndex} in
        1)
            build_Darwin
            ;;
        2)
            build_IOS
            ;;
        3)
            build_IOS_SIMULATOR
            ;;
        4)
            build_VISIONOS
            ;;
        5)
            build_Linux
            ;;
        6)
            build_Android
            ;;
        7)
            build_Windows
            ;;
        *)
            print_error "unsported platform!"
            exit -1
            ;;
        esac
        print_info "all libs will have been written into ${root_path}/libdav1d !"
    fi
}

root_path=$(pwd)
lib_path=${root_path}/bin/libdav1d.a
WORKSPACE=${root_path}/workspace
cur_sys=$(uname -s)
chmod 777 generate_project.sh
chmod 777 ${root_path}/build/apple/gas-preprocessor.pl
clear
setEnv

if [[ "${cur_sys}" == "Darwin" ]]; then
    print_info "build on $cur_sys"
elif [[ "${cur_sys}" == "Linux" ]]; then
    print_info "build on $cur_sys"
elif [[ "${cur_sys}" == *"${MINGW64_NT}"* ]]; then
    print_info "build on $cur_sys"
else
    print_info "build on $cur_sys"
    print_error "please specify sys you want to build on"
fi

ASM=1
for var in $*; do
    # Retrieve values for options first
    if [[ "${NextKey}" = "s" ]]; then
        PlatformIndex=${var}
        NextKey=""
    elif [[ "${NextKey}" = "asm" ]]; then
        ASM=${var}
        NextKey=""
    elif [[ "${NextKey}" = "ce" ]]; then
        cp_exe=${var}
        NextKey=""
    elif [[ "${NextKey}" = "cd" ]]; then
        cp_dynamic=${var}
        NextKey=""
    elif [[ ${var} = "-s" ]]; then
        NextKey="s"
    elif [[ ${var} = "-asm" ]]; then
        NextKey="asm"
    elif [[ ${var} = "-ce" ]]; then
        NextKey="ce"
    elif [[ ${var} = "-cd" ]]; then
        NextKey="cd"
    elif [[ ${var} = "-h" ]] || [[ ${var} = "--help" ]]; then
        print_usage
        exit -1
    else
        echo "ERROR: Invalid input $var"
    fi
done

if [ $? == 0 ]; then
    if [ ! -d "${WORKSPACE}" ]; then
        mkdir ${WORKSPACE}
    fi
    launch
fi
