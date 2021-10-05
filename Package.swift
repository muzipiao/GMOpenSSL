// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "openssl",
    platforms: [.iOS(.v9)],
    products: [
        .library(name: "openssl", targets: ["openssl"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(name: "openssl", path: "GMFrameworks/openssl.xcframework"),
    ]
)
