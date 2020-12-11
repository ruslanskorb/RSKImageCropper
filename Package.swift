// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RSKImageCropper",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "RSKImageCropper",
            targets: ["RSKImageCropper"]),
    ],
    targets: [
        .target(
            name: "RSKImageCropper",
            path: "RSKImageCropper",
            resources: [
                .copy("RSKImageCropperStrings.bundle")
            ],
            publicHeadersPath: "include"
        ),
    ]
)
