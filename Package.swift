// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GMOpenSSL",
    platforms: [.iOS(.v9)],
    products: [
        .library(name: "GMOpenSSL", targets: ["GMOpenSSL"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(name: "GMOpenSSL", path: "GMOpenSSL/openssl.xcframework"),
    ]
)
