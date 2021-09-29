#!/bin/sh
# 将 OpenSSL 打包为 XCFramework 格式库

# 需要编译的架构，确保与 build-libssl.sh 保持一致
DEFAULTTARGETS="ios-sim-cross-x86_64 ios64-cross-arm64"
BIN_TARGET_FOLDERS=""

# 获取二进制文件夹保存路径
get_bin_target_folders()
{
    TARGET_FOLDERS="$BIN_TARGET_FOLDERS"
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

    BIN_TARGET_FOLDERS="$TARGET_FOLDERS"
}

cd "$(dirname "$0")" || exit 0

# 判断是否已编译为.a
get_bin_target_folders "$DEFAULTTARGETS"
for TARGET_FOLDER in $BIN_TARGET_FOLDERS
do
    if [ ! -d "bin/${TARGET_FOLDER}" ]; then
        echo "Please run build-libssl.sh first!"
        exit 1
    fi
done

# fix inttypes.h
#find "${SCRIPT_DIR}/../iphoneos/include/openssl" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <sys\/types\.h>/g" {} \;
#find "${SCRIPT_DIR}/../iphonesimulator/include/openssl" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <sys\/types\.h>/g" {} \;

# fix headers for Swift

#sed -ie "s/BIGNUM \*I,/BIGNUM \*i,/g" ${SRC_DIR}/crypto/rsa/rsa_local.h   

# 编译为 framework
for TARGET_FOLDER in $BIN_TARGET_FOLDERS
do
    framework_path="bin/${TARGET_FOLDER}/openssl.framework"
    if [ -d "$framework_path" ]; then
        echo "Removing previous $framework_path copy"
        rm -rf "$framework_path"
    fi
    echo "Creating $framework_path"
    mkdir -p "$framework_path/Headers"
    libtool -no_warning_for_no_symbols -static -o "${framework_path}/openssl" "bin/${TARGET_FOLDER}/lib/libcrypto.a" "bin/${TARGET_FOLDER}/lib/libssl.a"
    cp -r bin/"${TARGET_FOLDER}"/include/openssl/* "${framework_path}"/Headers/
    # 添加 modulemap
    mkdir -p "$framework_path/Modules"
    cp Modules/module.modulemap "${framework_path}/Modules/"
    # 生成 openssl.h
    for h_path in bin/"${TARGET_FOLDER}"/include/openssl/*.h
    do
        h_name=$(basename "${h_path}")
        echo "#include <openssl/${h_name}>" >> "${framework_path}"/Headers/openssl.h
    done
done

# 编译为 xcframework
FRAMEWORK_PWD=""
for TARGET_FOLDER in $BIN_TARGET_FOLDERS
do
    if [ -z "$FRAMEWORK_PWD" ]; then
        FRAMEWORK_PWD="-framework bin/${TARGET_FOLDER}/openssl.framework"
    else
        FRAMEWORK_PWD="${FRAMEWORK_PWD} -framework bin/${TARGET_FOLDER}/openssl.framework"
    fi
done

if [ -d openssl.xcframework ]; then
    echo "Removing previous openssl.xcframework copy"
    rm -rf openssl.xcframework
fi

xcodebuild -create-xcframework ${FRAMEWORK_PWD} -output openssl.xcframework

