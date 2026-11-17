// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "MUDesignSystem",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "MUDesignSystem",
            targets: ["MUDesignSystem"]
        ),
    ],
    targets: [
        .target(name: "MUDesignSystem"),
    ]
)
