// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MUDesignSystem",
    platforms: [.iOS(.v16)], // Added platforms
    products: [
        .library(
            name: "MUDesignSystem",
            targets: ["MUDesignSystem"]
        ),
        .executable(
            name: "MUDesignSystemShowcase",
            targets: ["MUDesignSystemShowcase"]
        ),
    ],
    targets: [
        .target(
            name: "MUDesignSystem",
            resources: []
        ),
        .executableTarget(
            name: "MUDesignSystemShowcase",
            dependencies: ["MUDesignSystem"]
        ),
        .testTarget(
            name: "MUDesignSystemTests",
            dependencies: ["MUDesignSystem"]
        ),
    ]
)
