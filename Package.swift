// swift-tools-version: 6.0
import PackageDescription

let gtmSources = "ThirdParty/google-toolbox-for-mac/Sources"

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
            name: "GTMDefines",
            path: "\(gtmSources)/Defines",
            publicHeadersPath: "Public"
        ),
        .target(
            name: "GTMLogger",
            dependencies: ["GTMDefines"],
            path: "\(gtmSources)/Logger",
            exclude: [
                "BUILD",
                "GTMLogger+ASL.m",
                "GTMLoggerRingBufferWriter.m",
                "Resources",
            ],
            publicHeadersPath: "Public/Foundation"
        ),
        .target(
            name: "GTMNSData_zlib",
            dependencies: ["GTMDefines"],
            path: "\(gtmSources)/NSData_zlib",
            exclude: [
                "BUILD",
            ],
            publicHeadersPath: "Public/Foundation",
            linkerSettings: [
                .linkedLibrary("z"),
            ]
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
                "GTMLogger",
                "GTMNSData_zlib",
            ],
            path: "Sources/MLKitFaceDetectionKit",
            linkerSettings: [
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
