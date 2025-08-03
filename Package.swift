// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "popmart_trend_view",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "popmart_trend_view",
            targets: ["popmart_trend_view"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "popmart_trend_view"),
        .testTarget(
            name: "popmart_trend_viewTests",
            dependencies: ["popmart_trend_view"]
        ),
    ]
)
