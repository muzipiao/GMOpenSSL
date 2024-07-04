// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenSSL",
    platforms: [.iOS(.v12), .macOS(.v10_13)],
    products: [
        .library(name: "OpenSSL", targets: ["OpenSSL"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(name: "OpenSSL", path: "Frameworks/OpenSSL.xcframework"),
        .testTarget(name: "OpenSSLTests", dependencies: ["OpenSSL"]),
    ]
)
