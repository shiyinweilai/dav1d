#!/bin/sh

###############################################################################
# Copyright(C) 2021 - 2022 Tencent.
#
# All Rights Reserved.
###############################################################################

BASEPATH=`pwd`
WORKSPACE=./workspace
# platform[Linux, Darwin, Windows]
DEFAULT_PLATFORM=
# generator[Unix Makefiles, Xcode, Visual Studio, Android Studio]
DEFAULT_GENERATOR=
# machine[x86_32, x86_64, armv7, arm64]
DEFAULT_MACHINE=
DEFAULT_TYPE=
ENABLE_ASM=1
ADDITIONAL_PARAM=
TARGET_CPU=
BUILD_ON=

function USAGE() {
  echo "
  USAGE:
    ${0} [-s SYSTEM] [-a ARCHITECTURE] [-g GENERATOR]
      -s SYSTEM         target system;[Linux, Darwin, Win, Android, IOS]
      -a ARCHITECTURE   architecture;[x86_32, x86_64, armv7, armv7s, arm64, arm64e]
      -g GENERATOR      generator;[Unix Makefiles, Xcode, Visual Studio, Android Studio]
      -t TYPE           type;[Release, Debug]
      -d                use asan
  "
}

print_info(){
    echo -e " \033[32m [attention] ${1}\033[0m"
}

print_warning(){
    echo -e " \033[33m [attention] ${1}\033[0m"
}

function set_default_param() {
  if [ "${DEFAULT_PLATFORM}" == "" ]; then
    DEFAULT_PLATFORM=`uname -s`
  fi

  # 设置默认参数
  if [ "${DEFAULT_MACHINE}" == "" ]; then
    if [ "${DEFAULT_PLATFORM}" == "Linux" ]; then
      DEFAULT_MACHINE="x86_64"
    elif [ "${DEFAULT_PLATFORM}" == "Windows" ]; then
      DEFAULT_MACHINE="x86_64"
    elif [ "${DEFAULT_PLATFORM}" == "Darwin" ]; then
      DEFAULT_MACHINE="x86_64"
    elif [ "${DEFAULT_PLATFORM}" == "Android" ]; then
      DEFAULT_MACHINE="arm64"
    elif [ "${DEFAULT_PLATFORM}" == "IOS" ]; then
      DEFAULT_MACHINE="arm64"
    elif [ "${DEFAULT_PLATFORM}" == "IOS_SIMULATOR64" ]; then
      DEFAULT_MACHINE="x86_64"
    elif [ "${DEFAULT_PLATFORM}" == "IOS_SIMULATOR" ]; then
      DEFAULT_MACHINE="x86_32"
    elif [ "${DEFAULT_PLATFORM}" == "VISIONOS" ]; then
      DEFAULT_MACHINE="arm64"
    else
      DEFAULT_MACHINE=`uname -m`
    fi
  fi
  
  # 指令集架构检查
  if [ ${DEFAULT_MACHINE} != "x86_32" \
    -a ${DEFAULT_MACHINE} != "i386" \
    -a ${DEFAULT_MACHINE} != "x86_64" \
    -a ${DEFAULT_MACHINE} != "arm64_simu" \
    -a ${DEFAULT_MACHINE} != "armv7" \
    -a ${DEFAULT_MACHINE} != "armv7s" \
    -a ${DEFAULT_MACHINE} != "arm64" \
    -a ${DEFAULT_MACHINE} != "arm64e" \
    -a ${DEFAULT_MACHINE} != "arm64-v8a" \
    -a ${DEFAULT_MACHINE} != "armeabi-v7a" \
    -a ${DEFAULT_MACHINE} != "x86" \
    -a ${DEFAULT_MACHINE} != "armeabi" \
    -a ${DEFAULT_MACHINE} != "mac_catalyst_x86_64" ]; then
    echo "Unsupport Platform " ${DEFAULT_MACHINE}
    exit -1
  fi

  if [ "${DEFAULT_GENERATOR}" == "" ]; then
    if [ "${DEFAULT_PLATFORM}" == "Linux" ]; then
      DEFAULT_GENERATOR="Unix Makefiles"
    elif [ "${DEFAULT_PLATFORM}" == "Windows" ]; then
      DEFAULT_GENERATOR="Visual Studio 15 2017"
    elif [ "${DEFAULT_PLATFORM}" == "Darwin" ]; then
      DEFAULT_GENERATOR="Xcode"
    elif [ "${DEFAULT_PLATFORM}" == "MAC_CATALYST" ]; then
      DEFAULT_GENERATOR="Xcode"
    elif [ "${DEFAULT_PLATFORM}" == "Android" ]; then
      DEFAULT_GENERATOR="Unix Makefiles"
    elif [ "${DEFAULT_PLATFORM}" == "IOS" ]; then
      DEFAULT_GENERATOR="Xcode"
    elif [ "${DEFAULT_PLATFORM}" == "IOS_SIMULATOR" ]; then
      DEFAULT_GENERATOR="Xcode"
    elif [ "${DEFAULT_PLATFORM}" == "VISIONOS" ]; then
      DEFAULT_GENERATOR="Xcode"
    else
      DEFAULT_GENERATOR="Unix Makefiles"
    fi
  fi

  if [ "${DEFAULT_TYPE}" == "" ]; then
    DEFAULT_TYPE="Release"
  fi

  WORKSPACE=${WORKSPACE}"/"${DEFAULT_PLATFORM}"/"${DEFAULT_MACHINE}
  if [ "${DEFAULT_GENERATOR}" == "Unix Makefiles" ]; then
    WORKSPACE=${WORKSPACE}"/"${DEFAULT_TYPE}
  fi 

  echo "Default Params"
  echo -e "\tDEFAULT_PLATFORM" ${DEFAULT_PLATFORM}
  echo -e "\tDEFAULT_MACHINE" ${DEFAULT_MACHINE}
  echo -e "\tDEFAULT_GENERATOR" ${DEFAULT_GENERATOR}
  echo -e "\tDEFAULT_TYPE" ${DEFAULT_TYPE}
}

function parse_param() {
  echo "User Params"
  echo -e "\tDEFAULT_PLATFORM" ${DEFAULT_PLATFORM}
  echo -e "\tDEFAULT_MACHINE" ${DEFAULT_MACHINE}
  echo -e "\tDEFAULT_GENERATOR" ${DEFAULT_GENERATOR}
  echo -e "\tDEFAULT_TYPE" ${DEFAULT_TYPE}

  set_default_param

  #Linux
  if [ "${DEFAULT_PLATFORM}" == "Linux" ]; then
    if [ "${DEFAULT_MACHINE}" == "x86_64" ]; then
      ADDITIONAL_PARAM="-DLINUX_ARCH=x86_64"
      TARGET_CPU="x86_64"
    elif [ "${DEFAULT_MACHINE}" == "x86_32" ]; then
      ADDITIONAL_PARAM="-DLINUX_ARCH=x86_32"
      TARGET_CPU="x86_32"
    elif [ "${DEFAULT_MACHINE}" == "arm64" ]; then
      ADDITIONAL_PARAM="-DLINUX_ARCH=arm64"
      TARGET_CPU="arm64"
    elif [ "${DEFAULT_MACHINE}" == "armv7" ]; then
      ADDITIONAL_PARAM="-DLINUX_ARCH=armv7"
      TARGET_CPU="armv7"
    fi
  fi
  
  # Windows 平台
  if [ "${DEFAULT_PLATFORM}" == "Windows" ]; then
    if [ "${DEFAULT_MACHINE}" == "x86_64" ]; then
      DEFAULT_GENERATOR="Visual Studio 15 2017 Win64"
      ADDITIONAL_PARAM=" "
      TARGET_CPU="x86_64"
    elif [ "${DEFAULT_MACHINE}" == "x86_32" ]; then
      DEFAULT_GENERATOR="Visual Studio 15 2017"
      ADDITIONAL_PARAM=" "
      TARGET_CPU="x86_32"
    elif [ "${DEFAULT_MACHINE}" == "arm64" ]; then
      DEFAULT_GENERATOR="Visual Studio 17 2022"
      ADDITIONAL_PARAM=" -A ARM64 "
      TARGET_CPU="arm64"
      ENABLE_ASM=0
    elif [ "${DEFAULT_MACHINE}" == "armv7" ]; then
      DEFAULT_GENERATOR="Visual Studio 17 2022"
      ADDITIONAL_PARAM=" -A ARM "
      TARGET_CPU="armv7"
      ENABLE_ASM=0
    fi
  fi

  # Mac 平台
  if [ "${DEFAULT_PLATFORM}" == "Darwin" ]; then
    if [ "${DEFAULT_MACHINE}" == "mac_catalyst_x86_64" ]; then
      ADDITIONAL_PARAM="-T buildsystem=1 -D MAC_CATALYST=ON"
    else
      ADDITIONAL_PARAM="-T buildsystem=1"
    fi
  fi

  # IOS 真机
  if [ "${DEFAULT_PLATFORM}" == "IOS" ]; then
    if [ "${DEFAULT_MACHINE}" == "arm64" ]; then
      ADDITIONAL_PARAM="-T buildsystem=1 -DCMAKE_TOOLCHAIN_FILE=build/apple/ios.cmake -DIOS_PLATFORM=OS -DIOS_ARCH=arm64"
    elif [ "${DEFAULT_MACHINE}" == "arm64e" ]; then
      ADDITIONAL_PARAM="-T buildsystem=1 -DCMAKE_TOOLCHAIN_FILE=build/apple/ios.cmake -DIOS_PLATFORM=OS -DIOS_ARCH=arm64e"
      TARGET_CPU="aarch64"
    elif [ "${DEFAULT_MACHINE}" == "armv7" ]; then
      ADDITIONAL_PARAM="-T buildsystem=1 -DCMAKE_TOOLCHAIN_FILE=build/apple/ios.cmake -DIOS_PLATFORM=OS -DIOS_ARCH=armv7"
    elif [ "${DEFAULT_MACHINE}" == "armv7s" ]; then
      ADDITIONAL_PARAM="-T buildsystem=1 -DCMAKE_TOOLCHAIN_FILE=build/apple/ios.cmake -DIOS_PLATFORM=OS -DIOS_ARCH=armv7s"
      TARGET_CPU="armv7s"
    fi
  fi

  # IOS 模拟器
  if [ "${DEFAULT_PLATFORM}" == "IOS_SIMULATOR" ]; then
    if [ "${DEFAULT_MACHINE}" == "x86_64" ]; then
      ADDITIONAL_PARAM="-T buildsystem=1 -DCMAKE_TOOLCHAIN_FILE=build/apple/ios.toolchain.cmake -DPLATFORM=SIMULATOR64 -DIOS_ARCH=x86_64 -DDEPLOYMENT_TARGET='8.0'"
    elif [ "${DEFAULT_MACHINE}" == "i386" ]; then
      ADDITIONAL_PARAM="-T buildsystem=1 -DCMAKE_TOOLCHAIN_FILE=build/apple/ios.toolchain.cmake -DPLATFORM=SIMULATOR -DIOS_ARCH=i386 -DDEPLOYMENT_TARGET='8.0'"
    elif [ "${DEFAULT_MACHINE}" == "arm64_simu" ]; then
      ADDITIONAL_PARAM="-T buildsystem=1 -DCMAKE_TOOLCHAIN_FILE=build/apple/ios.toolchain.cmake -DPLATFORM=SIMULATORARM64 -DIOS_ARCH=arm64_simu -DDEPLOYMENT_TARGET='8.0'"  
    fi
  fi

  # VISOINOS 真机+模拟器 -DCMAKE_SYSTEM_NAME=iOS 
  VISIONOS_COMMON_CFG=" -DCMAKE_XCODE_ATTRIBUTE_XROS_DEPLOYMENT_TARGET='1.0' -DVISIONOS=1 -DAPPLE=1 -D CMAKE_C_COMPILER=/usr/bin/clang -D CMAKE_CXX_COMPILER=/usr/bin/clang++ "
  if [ "${DEFAULT_PLATFORM}" == "VISIONOS" ]; then
    if [ "${DEFAULT_MACHINE}" == "arm64" ]; then
      ADDITIONAL_PARAM="-DVISIONOS_ARCH=arm64  ${VISIONOS_COMMON_CFG} "
    elif [ "${DEFAULT_MACHINE}" == "arm64e" ]; then
      ADDITIONAL_PARAM="-DVISIONOS_ARCH=arm64e ${VISIONOS_COMMON_CFG} "
    elif [ "${DEFAULT_MACHINE}" == "arm64_simu" ]; then
      ADDITIONAL_PARAM="-DVISIONOS_ARCH=arm64 ${VISIONOS_COMMON_CFG} "
    elif [ "${DEFAULT_MACHINE}" == "x86_64" ]; then
      ADDITIONAL_PARAM="-DVISIONOS_ARCH=x86_64 ${VISIONOS_COMMON_CFG} "
    fi
  fi

  if [ "${DEFAULT_PLATFORM}" == "Android" ]; then
    if [ "${ANDROID_NDK}" == "" ]; then 
      echo "env ANDROID_NDK not found"
      echo "Please install android ndk and set env ANDROID_NDK"
      exit 1
    fi

    if [ "${DEFAULT_MACHINE}" == "arm64-v8a" ]; then
      ADDITIONAL_PARAM="-DANDROID=1 -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake -DANDROID_ABI=arm64-v8a -DANDROID_NATIVE_API_LEVEL=21 -DANDROID_NDK=${ANDROID_NDK}/"
    elif [ "${DEFAULT_MACHINE}" == "armeabi-v7a" ]; then
      ADDITIONAL_PARAM="-DANDROID=1 -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake -DANDROID_ABI=armeabi-v7a -DANDROID_NATIVE_API_LEVEL=21 -DANDROID_NDK=${ANDROID_NDK}/"
    elif [ "${DEFAULT_MACHINE}" == "armeabi" ]; then
      ADDITIONAL_PARAM="-DANDROID=1 -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake -DANDROID_ABI=armeabi -DANDROID_NATIVE_API_LEVEL=21 -DANDROID_NDK=${ANDROID_NDK}/"
    elif [ "${DEFAULT_MACHINE}" == "x86_64" ]; then
      ADDITIONAL_PARAM="-DANDROID=1 -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake -DANDROID_ABI=x86_64 -DANDROID_NATIVE_API_LEVEL=21 -DANDROID_NDK=${ANDROID_NDK}/"
    elif [ "${DEFAULT_MACHINE}" == "x86" ]; then
      ADDITIONAL_PARAM="-DANDROID=1 -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake -DANDROID_ABI=x86 -DANDROID_NATIVE_API_LEVEL=21 -DANDROID_NDK=${ANDROID_NDK}/"
    fi
  fi
  
  if [ "${DEFAULT_MACHINE}" == "arm64" ] || [ "${DEFAULT_MACHINE}" == "arm64_simu" ] || [ "${DEFAULT_MACHINE}" == "arm64-v8a" ]; then
    TARGET_CPU="aarch64"
  elif [ "${DEFAULT_MACHINE}" == "armv7" ] || [ "${DEFAULT_MACHINE}" == "armeabi-v7a" ]; then
    TARGET_CPU="armv7"
  fi

  # 是否开启汇编
  ADDITIONAL_PARAM=${ADDITIONAL_PARAM}" -DENABLE_ASM="${ENABLE_ASM}
}

function prepare_workspace() {
  echo "prepare_workspace Params"
  echo -e "\tDEFAULT_PLATFORM" ${DEFAULT_PLATFORM}
  echo -e "\tDEFAULT_MACHINE" ${DEFAULT_MACHINE}
  echo -e "\tDEFAULT_GENERATOR" ${DEFAULT_GENERATOR}
  echo -e "\tDEFAULT_TYPE" ${DEFAULT_TYPE}

  if [ -d ${WORKSPACE}} ]; then
    rm -rf ${WORKSPACE}
  fi 

  mkdir -p ${WORKSPACE}
}

function execute_cmake() {
  if [ "${DEFAULT_PLATFORM}" == "Windows" ]; then
    echo -e "cmd: \n cmake -H${BASEPATH} -B${WORKSPACE} -G"${DEFAULT_GENERATOR}" -DCMAKE_BUILD_TYPE=${DEFAULT_TYPE} -DCMAKE_SYSTEM_NAME=${DEFAULT_PLATFORM} -DCMAKE_SYSTEM_PROCESSOR=${TARGET_CPU} -DUSE_ASAN=0 ${ADDITIONAL_PARAM}"
    cmake -H${BASEPATH} -B${WORKSPACE} -G"${DEFAULT_GENERATOR}" -DCMAKE_BUILD_TYPE=${DEFAULT_TYPE} -DCMAKE_SYSTEM_NAME=${DEFAULT_PLATFORM} -DCMAKE_SYSTEM_PROCESSOR=${TARGET_CPU} -DUSE_ASAN=0 ${ADDITIONAL_PARAM}
    print_warning "注意，如果出现错误：“No CMAKE_C_COMPILER could be found.”，可能是你的visual studio没有安装对应的arm64或armv7编译器"
  elif [ "${DEFAULT_PLATFORM}" == "VISIONOS" ]; then
    echo -e "cmd: \n cmake -H${BASEPATH} -B${WORKSPACE} -G"${DEFAULT_GENERATOR}" -DCMAKE_BUILD_TYPE=${DEFAULT_TYPE} -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_SYSTEM_PROCESSOR=${TARGET_CPU} -DBUILD_ON=${BUILD_ON} ${ADDITIONAL_PARAM}"
    cmake -H${BASEPATH} -B${WORKSPACE} -G"${DEFAULT_GENERATOR}" -DCMAKE_BUILD_TYPE=${DEFAULT_TYPE} -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_SYSTEM_PROCESSOR=${TARGET_CPU} -DBUILD_ON=${BUILD_ON} ${ADDITIONAL_PARAM}
  else
    cd ${WORKSPACE}
    if [[ ${DEFAULT_PLATFORM} == "Darwin" ]] && [[ $DEFAULT_MACHINE == "arm64" ]];then  # M1芯片Macos arm64版
      cmake ../../../ -D CMAKE_BUILD_TYPE=Release -G "Xcode" -D CMAKE_C_COMPILER=/usr/bin/clang -D CMAKE_CXX_COMPILER=/usr/bin/clang++ -D APPLE=ON -D MACOS_ARM64=ON
    else
      echo ${ADDITIONAL_PARAM}
      BUILD_ON=`uname -s`
      echo -e "\t cmake command is : cmake -G${DEFAULT_GENERATOR} -DCMAKE_BUILD_TYPE=${DEFAULT_TYPE} -DCMAKE_SYSTEM_NAME=${DEFAULT_PLATFORM} -DCMAKE_SYSTEM_PROCESSOR=${TARGET_CPU} -DBUILD_ON=${BUILD_ON} ${ADDITIONAL_PARAM} ${BASEPATH}" 
      cmake -G"${DEFAULT_GENERATOR}" -DCMAKE_BUILD_TYPE=${DEFAULT_TYPE} -DCMAKE_SYSTEM_NAME=${DEFAULT_PLATFORM} -DCMAKE_SYSTEM_PROCESSOR=${TARGET_CPU} -DBUILD_ON=${BUILD_ON} ${ADDITIONAL_PARAM} ${BASEPATH}
    fi
  fi

}

print_info "=====================================配置开始====================================="
chmod 777 ${BASEPATH}/build/apple/gas-preprocessor.pl

get_param_from_urer(){
  for var in $*;do
      # Retrieve values for options first
      if [[ "${NextKey}" = "s" ]]; then
          DEFAULT_PLATFORM=${var}
          NextKey=""
      elif [[ "${NextKey}" = "asm" ]]; then
          ENABLE_ASM=${var}
          NextKey=""
      elif [[ "${NextKey}" = "a" ]]; then
          DEFAULT_MACHINE=${var}
          NextKey=""
      elif [[ "${NextKey}" = "dl" ]]; then
          cp_dynamic=${var}
          NextKey=""
      elif [[ ${var} = "-s" ]]; then
          NextKey="s"
      elif [[ ${var} = "-asm" ]]; then
          NextKey="asm"
      elif [[ ${var} = "-a" ]]; then
          NextKey="a"
      elif [[ ${var} = "-dl" ]]; then
          NextKey="dl"
      else
          echo "Invalid input $var"
          exit -1
      fi
  done

}
get_param_from_urer $*
parse_param
prepare_workspace
execute_cmake
print_info "=====================================配置结束====================================="

exit 0
