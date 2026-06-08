// swift-tools-version: 5.7

import PackageDescription

let version = "4.4.0"
let checksum = "1de5ec6688ca6733da1bf0eed5754878ece134223fbd43ede86df6af99c8eee0"

// ZoomVideoSDK xcframework + its transitive dyld dependencies.
// PagerKit.xcframework directly links against `ZoomVideoSDK`, `CptShare`,
// `zoomcml` and `zm_annoter_dynamic` (see `otool -L PagerKit.framework/PagerKit`);
// `ZoomVideoSDK` additionally has a runtime `@rpath` dependency on `ZoomTask`.
// All of these must be linked (and therefore embedded by the consuming app)
// or dyld aborts at launch with e.g.
// "Library not loaded: @rpath/CptShare.framework/CptShare".
// All pinned to v2.4.12 from Zoom's official GitHub releases.
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
                "CptShare",
                "zoomcml",
                "zm_annoter_dynamic",
                .product(name: "Pendo", package: "pendo-mobile-sdk"),
            ]
        ),
        .binaryTarget(
            name: "PagerKitBinary",
            url: "https://pagerinc.jfrog.io/pagerinc/swift-release/PagerKit/PagerKit-\(version).xcframework.zip",
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
        .binaryTarget(
            name: "CptShare",
            url: "https://github.com/zoom/videosdk-ios/releases/download/\(zoomVersion)/CptShare.xcframework.zip",
            checksum: "95a50c7511019c4bff8e359ad292536eb1b727a8ce1eb957fbf73d5cace19899"
        ),
        .binaryTarget(
            name: "zoomcml",
            url: "https://github.com/zoom/videosdk-ios/releases/download/\(zoomVersion)/zoomcml.xcframework.zip",
            checksum: "5d4576c60ea44aead52cb49f2d6ac0eecbb8f35c57d6452a759caddf691a06d1"
        ),
        .binaryTarget(
            name: "zm_annoter_dynamic",
            url: "https://github.com/zoom/videosdk-ios/releases/download/\(zoomVersion)/zm_annoter_dynamic.xcframework.zip",
            checksum: "92989278e8c663f137dd2f26dd96ed605af06f1f3d64d374ff5ef14aae082cae"
        ),
    ]
)
