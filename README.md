# GMOpenSSL

[![Pod Version](https://img.shields.io/badge/pod-3.0.3-blue)](https://cocoapods.org/pods/GMOpenSSL)
[![Platform](https://img.shields.io/badge/platform-ios%20%7C%20osx-lightgrey)](https://cocoapods.org/pods/GMOpenSSL)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/muzipiao/GMOpenSSL)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Mac Catalyst compatible](https://img.shields.io/badge/Catalyst-compatible-brightgreen.svg)](https://developer.apple.com/documentation/xcode/creating_a_mac_version_of_your_ipad_app/)
[![License](https://img.shields.io/badge/license-MIT-green)](https://cocoapods.org/pods/GMOpenSSL)

cocoapods 不支持直接集成 OpenSSL，将 OpenSSL 源码编译为 framework，并发布至 cocoapods，名称为 GMOpenSSL，方便通过 cocoapods 集成。

## 版本映射

|GMOpenSSL 版本|OpenSSL 版本|支持架构|Bitcode|兼容版本|
|:---:|:---:|:---:|:---:|:---:|
|3.0.5|1.1.1u|x86_64 arm64|不包含|iOS>= iOS 9.0, OSX>=10.13|
|2.2.9|1.1.1q|x86_64 arm64|包含|>= iOS 9.0|
|2.2.4|1.1.1l|x86_64 arm64 arm64e armv7 armv7s|包含|>= iOS 8.0|

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
    .package(url: "https://github.com/muzipiao/GMOpenSSL.git", from: "3.0.3")
],
```

## 自定义编译 OpenSSL

如果编译的静态库不能满足需求，可以自行运行脚本编译。工程目录下有一个名称为 OpenSSL_BUILD 的文件夹，依次执行 cd 切换到当前目录下，然后执行`make`即可，待执行完毕，即可看到编译完成的 `OpenSSL_BUILD/Frameworks/OpenSSL.xcframwork`。静态库在对应平台的 lib 文件夹下，如`iphoneos/lib/libcrypto.a`。

编译工程依赖[开源项目OpenSSL](https://github.com/krzyzanowskim/OpenSSL)，由于此项目未暴露国密头文件，本目录与原项目有小量改动；主要改动为将 OpenSSL 源码 include/crypto/ 路径下的 sm2.h、sm3.h，sm4.h 都拷贝至项目。

**主要步骤：**

1. 将`OpenSSL_BUILD/gmheaders`文件夹下头文件夹拖至项目，并设置头文件依赖为**public**；
2. 在`OpenSSL_BUILD/support`目录下的`OpenSSL.h`中添加下方导入，然后执行`make`编译即可；

```objc
#include <OpenSSL/sm2.h>
#include <OpenSSL/sm3.h>
#include <OpenSSL/sm4.h>
```
