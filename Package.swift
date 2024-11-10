// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NavigationViewElastic",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "NavigationViewElastic",
            targets: ["NavigationViewElastic"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NavigationViewElastic",
            dependencies: [],
            swiftSettings: [.define("DEBUG", .when(configuration: .debug))]
        )
    ]
)
