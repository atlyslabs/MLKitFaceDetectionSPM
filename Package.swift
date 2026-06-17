// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MLKitFaceDetectionSPM",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "MLKitFaceDetection",
            type: .static,
            targets: ["MLKitFaceDetectionKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/google/gtm-session-fetcher.git", from: "3.5.0"),
        .package(url: "https://github.com/google/GoogleUtilities.git", from: "8.0.0"),
        .package(url: "https://github.com/google/GoogleDataTransport.git", from: "10.0.0"),
        .package(path: "ThirdParty/google-toolbox-for-mac"),
    ],
    targets: [
        .binaryTarget(
            name: "MLImage",
            path: "Frameworks/MLImage.xcframework"
        ),
        .binaryTarget(
            name: "MLKitCommon",
            path: "Frameworks/MLKitCommon.xcframework"
        ),
        .binaryTarget(
            name: "MLKitVision",
            path: "Frameworks/MLKitVision.xcframework"
        ),
        .binaryTarget(
            name: "MLKitFaceDetection",
            path: "Frameworks/MLKitFaceDetection.xcframework"
        ),
        .target(
            name: "MLKitFaceDetectionKit",
            dependencies: [
                "MLImage",
                "MLKitCommon",
                "MLKitVision",
                "MLKitFaceDetection",
                .product(name: "GTMSessionFetcherCore", package: "gtm-session-fetcher"),
                .product(name: "GULLogger", package: "GoogleUtilities"),
                .product(name: "GULUserDefaults", package: "GoogleUtilities"),
                .product(name: "GoogleDataTransport", package: "GoogleDataTransport"),
                .product(name: "GTMLogger", package: "google-toolbox-for-mac"),
                .product(name: "GTMNSData_zlib", package: "google-toolbox-for-mac"),
            ],
            path: "Sources/MLKitFaceDetectionKit",
            linkerSettings: [
                .unsafeFlags(["-ObjC"]),
                .linkedLibrary("c++"),
                .linkedLibrary("dl"),
                .linkedLibrary("m"),
                .linkedLibrary("pthread"),
                .linkedLibrary("z"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("Accelerate"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreImage"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("CoreTelephony"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("Foundation"),
                .linkedFramework("OSLog"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("Security"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("UIKit"),
            ]
        ),
    ]
)
