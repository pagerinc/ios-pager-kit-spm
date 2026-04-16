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
        .package(url: "https://github.com/zoom/videosdk-ios.git", branch: "swift-package-manager"),
        .package(url: "https://github.com/pendo-io/pendo-mobile-sdk.git", from: "3.9.1"),
    ],
    targets: [
        .target(
            name: "PagerKitSDK",
            dependencies: [
                "PagerKitBinary",
                .product(name: "ZoomVideoSDK", package: "videosdk-ios"),
                .product(name: "Pendo", package: "pendo-mobile-sdk"),
            ],
            path: "Sources/PagerKit"
        ),
        .binaryTarget(
            name: "PagerKitBinary",
            url: "https://pagerinc.jfrog.io/pagerinc/swift-release-local/PagerKit/PagerKit-\(version).xcframework.zip",
            checksum: checksum
        ),
    ]
)
