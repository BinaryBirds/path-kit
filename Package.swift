// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "path-kit",
    products: [
        .library(name: "PathKit", targets: ["PathKit"]),
        .library(name: "PathKitDynamic", type: .dynamic, targets: ["PathKit"])
    ],
    targets: [
        .target(name: "PathKit", dependencies: []),
        .testTarget(name: "PathKitTests", dependencies: ["PathKit"]),
    ]
)
