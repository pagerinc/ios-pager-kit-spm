// swift-tools-version: 5.7

import PackageDescription

let version = "4.6.0"
let checksum = "cfdb74449aca94aa614fb847681c20ff3112d51c2a48de31a5be89815151197f"

// ZoomVideoSDK xcframework + its transitive dyld dependencies.
// PagerKit.xcframework directly links against `ZoomVideoSDK`, `CptShare`,
// `zoomcml` and `zm_annoter_dynamic` (see `otool -L PagerKit.framework/PagerKit`);
// `ZoomVideoSDK` additionally has a runtime `@rpath` dependency on `ZoomTask`.
// All of these must be linked (and therefore embedded by the consuming app)
// or dyld aborts at launch with e.g.
// "Library not loaded: @rpath/CptShare.framework/CptShare".
// All pinned to v2.5.7 from Zoom's official GitHub releases (matches the
// ZoomVideoSDK version ios-pager-kit consumes; 2.5.0/2.5.5 ship only the
// umbrella bundle, so v2.5.7 is the nearest tag with standalone xcframework zips).
let zoomVersion = "v2.5.7"

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
            checksum: "9400de4b4c25029647d58c27e67d074e6f428f8c2d7eaf932bc7b40c27fbe135"
        ),
        .binaryTarget(
            name: "ZoomTask",
            url: "https://github.com/zoom/videosdk-ios/releases/download/\(zoomVersion)/ZoomTask.xcframework.zip",
            checksum: "d336a853032bcd77ef995ccae17299bd8263fdb7fa2e27689b5e0a4df6d42451"
        ),
        .binaryTarget(
            name: "CptShare",
            url: "https://github.com/zoom/videosdk-ios/releases/download/\(zoomVersion)/CptShare.xcframework.zip",
            checksum: "387aabfd5f91d9a800e3de7860a5bfadd29ded35eeeb1464624fa1adcdc2490a"
        ),
        .binaryTarget(
            name: "zoomcml",
            url: "https://github.com/zoom/videosdk-ios/releases/download/\(zoomVersion)/zoomcml.xcframework.zip",
            checksum: "f0c0a68a7393f8ad2f5e7c4689db9907ed9f5d1d0f1900eb01d6ae3f0d8c0b3a"
        ),
        .binaryTarget(
            name: "zm_annoter_dynamic",
            url: "https://github.com/zoom/videosdk-ios/releases/download/\(zoomVersion)/zm_annoter_dynamic.xcframework.zip",
            checksum: "35d82428f7d3b4d56dd2a1a65f2a5d6c82b40b2f1e3688c33944de2357be0b94"
        ),
    ]
)
