// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTTPEngine",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "HTTPEngine",
            targets: ["HTTPEngine"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JZDesign/SwiftUtilities.git", .upToNextMajor(from: "0.1.0")),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", .upToNextMajor(from: "9.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "HTTPEngine",
            dependencies: ["SwiftUtilities"]),
        .testTarget(
            name: "HTTPEngineTests",
            dependencies: [
                "HTTPEngine",
                .product(name: "OHHTTPStubs", package: "OHHTTPStubs"),
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")]
        ),
    ]
)
