// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DashCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "DashCore", targets: ["DashCore"]),
    ],
    targets: [
        .target(name: "DashCore"),
        .testTarget(name: "DashCoreTests", dependencies: ["DashCore"]),
    ]
)
