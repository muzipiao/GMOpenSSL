# GMOpenSSL

[![Version](https://img.shields.io/cocoapods/v/GMOpenSSL.svg?style=flat)](https://cocoapods.org/pods/GMOpenSSL)
[![License](https://img.shields.io/cocoapods/l/GMOpenSSL.svg?style=flat)](https://cocoapods.org/pods/GMOpenSSL)
[![Platform](https://img.shields.io/cocoapods/p/GMOpenSSL.svg?style=flat)](https://cocoapods.org/pods/GMOpenSSL)

cocoapods 不支持直接集成 OpenSSL，将 OpenSSL 1.1.1c 源码编译为 framework，并发布至 cocoapods，名称为 GMOpenSSL，方便通过 cocoapods 集成。

## CocoaPods

CocoaPods 是最简单方便的集成方法，编辑 Podfile 文件，添加

```ruby
pod 'GMOpenSSL'
```

然后执行 `pod install` 即可。

## 自定义编译 OpenSSL

如果编译的静态库不能满足需求，可以自行运行脚本编译。工程目录下有一个名称为 OpenSSL_BUILD 的文件夹，依次执行 cd 切换到当前目录下，然后执行`./build-libssl.sh`，待执行完毕再执行`./create-openssl-framework.sh`，即可看到编译完成的 openssl.framwork。
