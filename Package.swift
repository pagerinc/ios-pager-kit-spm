// swift-tools-version: 5.7

import PackageDescription

let version = "4.3.0"
let checksum = "1746698c750672bdcc65a3f0e326c036fc160a9cda958eef07f506a5d63ed20d"

let package = Package(
    name: "PagerKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PagerKit",
            targets: ["PagerKitSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pendo-io/pendo-mobile-sdk.git", from: "3.9.1"),
    ],
    targets: [
        .target(
            name: "PagerKitSDK",
            dependencies: [
                "PagerKitBinary",
                "ZoomVideoSDK",
                .product(name: "Pendo", package: "pendo-mobile-sdk"),
            ],
            path: "Sources/PagerKit"
        ),
        .binaryTarget(
            name: "PagerKitBinary",
            url: "https://pagerinc.jfrog.io/pagerinc/swift-release-local/PagerKit/PagerKit-\(version).xcframework.zip",
            checksum: checksum
        ),
        .binaryTarget(
            name: "ZoomVideoSDK",
            url: "https://github.com/zoom/videosdk-ios/releases/download/v2.4.12/ZoomVideoSDK.xcframework.zip",
            checksum: "c60008b4571c102498697f0e049a714994aa09a44790f6d7287d2a6cac112ebd"
        ),
    ]
)
