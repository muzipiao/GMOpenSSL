#!/bin/sh
# 将 OpenSSL 打包为 XCFramework 格式库

# 需要编译的架构，确保与 build-libssl.sh 保持一致
DEFAULTTARGETS="ios-sim-cross-x86_64 ios64-cross-arm64"
TARGET_FOLDERS=""

# 获取二进制文件夹保存路径
get_target_folders()
{
    IOS_SDKVERSION=$(xcrun -sdk iphoneos --show-sdk-version)

    for TARGET_NAME in $1
    do
        PLATFORM=""
        # Determine platform
        if [[ "${TARGET_NAME}" == "ios-sim-cross-"* ]]; then
            PLATFORM="iPhoneSimulator"
        elif [[ "${TARGET_NAME}" == "tvos-sim-cross-"* ]]; then
            PLATFORM="AppleTVSimulator"
        elif [[ "${TARGET_NAME}" == "tvos64-cross-"* ]]; then
            PLATFORM="AppleTVOS"
        elif [[ "${TARGET_NAME}" == "mac-catalyst-"* ]]; then
            PLATFORM="MacOSX"
        else
            PLATFORM="iPhoneOS"
        fi

        ARCH="${TARGET_NAME##*-}"
        if [ -z "$TARGET_FOLDERS" ]; then
            TARGET_FOLDERS="${PLATFORM}${IOS_SDKVERSION}-${ARCH}.sdk"
        else
            TARGET_FOLDERS="${TARGET_FOLDERS} ${PLATFORM}${IOS_SDKVERSION}-${ARCH}.sdk"
        fi
    done
}

cd "$(dirname "$0")" || exit 1

# 判断是否已编译为.a
get_target_folders "$DEFAULTTARGETS"
for TARGET_FOLDER in $TARGET_FOLDERS
do
    if [ ! -d "OpenSSL_BUILD/bin/${TARGET_FOLDER}" ]; then
        echo "Please run build-libssl.sh first!"
        exit 1
    fi
done

# 编译为 framework
for TARGET_FOLDER in $TARGET_FOLDERS
do
    # 如果存在已生成的 framework，先移除旧的
    bin_target_folder="OpenSSL_BUILD/bin/${TARGET_FOLDER}"
    framework_path="${bin_target_folder}/openssl.framework"
    if [ -d "$framework_path" ]; then
        echo "Removing previous $framework_path copy"
        rm -rf "$framework_path"
    fi
    echo "Creating $framework_path"
    mkdir -p "$framework_path/Headers"
    libtool -no_warning_for_no_symbols -static -o "${framework_path}/openssl" "${bin_target_folder}/lib/libcrypto.a" "${bin_target_folder}/lib/libssl.a"
    # 拷贝 sm2.h sm3.h sm4.h
    cp OpenSSL_BUILD/xc-template/*.h "${bin_target_folder}"/include/openssl/
    # fix inttypes.h
    find "${bin_target_folder}"/include/openssl -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <sys\/types\.h>/g" {} \;
    # 复制头文件夹
    if [ -f "${bin_target_folder}"/include/openssl/asn1_mac.h ]; then
        rm "${bin_target_folder}"/include/openssl/asn1_mac.h
    fi
    cp -r "${bin_target_folder}"/include/openssl/* "${framework_path}"/Headers/
    # 添加 modulemap
    mkdir -p "$framework_path/Modules"
    cp OpenSSL_BUILD/xc-template/module.modulemap "${framework_path}/Modules/"
    # 生成 openssl.h
    for h_path in "${bin_target_folder}"/include/openssl/*.h
    do
        h_name=$(basename "${h_path}")
        echo "#include <openssl/${h_name}>" >> "${framework_path}"/Headers/openssl.h
    done
done

# 编译为 xcframework
FRAMEWORK_PWD=""
for TARGET_FOLDER in $TARGET_FOLDERS
do
    if [ -z "$FRAMEWORK_PWD" ]; then
        FRAMEWORK_PWD="-framework OpenSSL_BUILD/bin/${TARGET_FOLDER}/openssl.framework"
    else
        FRAMEWORK_PWD="${FRAMEWORK_PWD} -framework OpenSSL_BUILD/bin/${TARGET_FOLDER}/openssl.framework"
    fi
done

if [ -d GMFrameworks/openssl.xcframework ]; then
    echo "Removing previous openssl.xcframework copy"
    rm -rf GMFrameworks/openssl.xcframework
fi

xcodebuild -create-xcframework ${FRAMEWORK_PWD} -output GMFrameworks/openssl.xcframework

