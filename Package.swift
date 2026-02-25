// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MLCMSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MLCMSDK",
            targets: ["MLCMSDK"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/SDWebImage/SDWebImage.git",
            from: "5.0.0"
        )
    ],
    targets: [
        .target(
            name: "MLCMSDK",
            dependencies: [
                "SDWebImage"
            ],
            resources: [
                .process("Asset.xcassets"),
                .process("PopupControllers/BottomDetailsPopupViewController.xib"),
                .process("PopupControllers/FullPageWebViewViewController.xib"),
                .process("PopupControllers/QuickTipsViewController.xib"),
                .process("PopupControllers/ShowHtmlContentViewController.xib"),
                .process("PopupControllers/SingleCenterInfoViewController.xib"),
                .process("PopupControllers/SingleImagePopupViewController.xib")
            ]
        )
    ]
)
