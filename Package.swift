// swift-tools-version: 5.7

import PackageDescription

let version = "4.4.0-rc.1"
let checksum = "fb17694b8b56aebcaa57ed71192b8340f3bb5a9b09a2dade4257d14b4041981c"

// ZoomVideoSDK xcframework + its transitive dyld dependencies.
// PagerKit.xcframework directly links against `ZoomVideoSDK`; `ZoomVideoSDK`
// has a runtime `@rpath` dependency on `ZoomTask` that must also be linked.
// Both pinned to v2.4.12 from Zoom's official GitHub releases.
let zoomVersion = "v2.4.12"

let package = Package(
    name: "PagerKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PagerKit",
            targets: ["PagerKitWrapper"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pendo-io/pendo-mobile-sdk.git", from: "3.9.1"),
    ],
    targets: [
        // Wrapper target that forces the consumer to link PagerKit's
        // transitive runtime dependencies (ZoomVideoSDK, ZoomTask, Pendo).
        // Consumers import `PagerKit` (the product name), which resolves
        // to the binary target's internal `PagerKit` module — not to this
        // wrapper. See Sources/PagerKitWrapper/PagerKitWrapper.swift.
        .target(
            name: "PagerKitWrapper",
            dependencies: [
                "PagerKitBinary",
                "ZoomVideoSDK",
                "ZoomTask",
                .product(name: "Pendo", package: "pendo-mobile-sdk"),
            ]
        ),
        .binaryTarget(
            name: "PagerKitBinary",
            url: "https://pagerinc.jfrog.io/pagerinc/swift-release-local/PagerKit/PagerKit-\(version).xcframework.zip",
            checksum: checksum
        ),
        .binaryTarget(
            name: "ZoomVideoSDK",
            url: "https://github.com/zoom/videosdk-ios/releases/download/\(zoomVersion)/ZoomVideoSDK.xcframework.zip",
            checksum: "c60008b4571c102498697f0e049a714994aa09a44790f6d7287d2a6cac112ebd"
        ),
        .binaryTarget(
            name: "ZoomTask",
            url: "https://github.com/zoom/videosdk-ios/releases/download/\(zoomVersion)/ZoomTask.xcframework.zip",
            checksum: "1c912bb69e3060be21583c3b8897f11f68ae63d883c1d4d851e3e6ab8a300ddb"
        ),
    ]
)
