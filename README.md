# GMOpenSSL

[![Pod Version](https://img.shields.io/cocoapods/v/GMOpenSSL.svg?style=flat)](https://cocoapods.org/pods/GMOpenSSL)
[![Platform](https://img.shields.io/badge/platform-ios%20%7C%20osx-lightgrey)](https://cocoapods.org/pods/GMOpenSSL)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/muzipiao/GMOpenSSL)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Mac Catalyst compatible](https://img.shields.io/badge/Catalyst-compatible-brightgreen.svg)](https://developer.apple.com/documentation/xcode/creating_a_mac_version_of_your_ipad_app/)
[![License](https://img.shields.io/badge/license-MIT-green)](https://cocoapods.org/pods/GMOpenSSL)

cocoapods 不支持直接集成 OpenSSL，将 OpenSSL 源码编译为 framework，并发布至 cocoapods，名称为 GMOpenSSL，方便通过 cocoapods 集成。

此项目主要作为国密开源库 [GMObjC](https://muzipiao.github.io/gmdocs/) 依赖库，也可以单独使用。

## 版本映射

| GMOpenSSL 版本 | OpenSSL 版本 |             支持架构             | Bitcode |         兼容版本          |
| :------------: | :----------: | :------------------------------: | :-----: | :-----------------------: |
|     3.1.2      |    1.1.1w    |           x86_64 arm64           | 不包含  | iOS>= iOS 9.0, OSX>=10.13 |
|     2.2.9      |    1.1.1q    |           x86_64 arm64           |  包含   |        >= iOS 9.0         |
|     2.2.4      |    1.1.1l    | x86_64 arm64 arm64e armv7 armv7s |  包含   |        >= iOS 8.0         |

## CocoaPods

CocoaPods 是最简单方便的集成方法，编辑 Podfile 文件，添加

```ruby
pod 'GMOpenSSL'
```

然后执行 `pod install` 即可，默认最新版本。

### Swift Package Manager

GMOpenSSL 支持 SwiftPM，在工程中使用，点击 `File` -> `Swift Packages` -> `Add Package Dependency`，输入 [https://github.com/muzipiao/GMOpenSSL.git](https://github.com/muzipiao/GMOpenSSL.git)，或者在 Xcode 中添加 GitHub 账号，搜索 `GMOpenSSL` 即可。

如果在组件库中使用，更新 `Package.swift` 文件：

```swift
dependencies: [
    .package(url: "https://github.com/muzipiao/GMOpenSSL.git", from: "3.1.2")
],
```

## 自定义编译 OpenSSL

如果编译的静态库不能满足需求，可以自行运行脚本编译。

1. 终端执行命令`git clone https://github.com/muzipiao/GMOpenSSL.git`下载项目至本地；
2. 打开项目的`GMOpenSSL/OpenSSL_BUILD/OpenSSL.xcodeproj`工程，根据需要修改配置静态库；
3. 切换到`OpenSSL_BUILD`的文件夹，执行命令`cd GMOpenSSL/OpenSSL_BUILD && make`；
4. 执行完毕，可看到编译完成的 `OpenSSL_BUILD/Frameworks/OpenSSL.xcframwork`文件。

编译工程依赖[开源项目OpenSSL](https://github.com/krzyzanowskim/OpenSSL)，由于它未暴露国密头文件，本目录与原项目有小量改动；主要改动为将 OpenSSL 源码 include/crypto/ 路径下的 sm2.h、sm3.h，sm4.h 都拷贝至项目。

**修改原理讲解：**

1. 将`OpenSSL_BUILD/gmheaders`文件夹下头文件夹拖至项目，并设置头文件依赖为**public**；
2. 在`OpenSSL_BUILD/support`目录下的`OpenSSL.h`中添加下方导入，然后执行`make`编译即可；

```objc
#include <OpenSSL/sm2.h>
#include <OpenSSL/sm3.h>
#include <OpenSSL/sm4.h>
```

## 可能遇到的错误

### 二进制文件因签名审核被拒：

```text
ITMS-91065: Missing signature - Your app includes “Frameworks/OpenSSL.framework/OpenSSL”, which includes BoringSSL / openssl_grpc, an SDK that was identified in the documentation as a privacy-impacting third-party SDK. If a new app includes a privacy-impacting SDK, or an app update adds a new privacy-impacting SDK, the SDK must include a signature file. Please contact the provider of the SDK that includes this file to get an updated SDK version with a signature.
```

**解决办法**，对指定二进制文件手动签名即可，可参考[issues 92](https://github.com/muzipiao/GMObjC/issues/92)。

```shell
# 查看签名，无签名显示 code object is not signed at all
codesign -dv --verbose=4 OpenSSL.xcframework
# 钥匙串复制证书名称，执行此命令即可签名。
xcrun codesign --timestamp -s "证书全称" OpenSSL.xcframework
# 验证签名
xcrun codesign --verify --verbose OpenSSL.xcframework
```
