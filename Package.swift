// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "path-kit",
    products: [
        .library(name: "PathKit", targets: ["PathKit"]),
    ],
    targets: [
        .target(name: "PathKit", dependencies: []),
        .testTarget(name: "PathKitTests", dependencies: ["PathKit"]),
    ]
)
