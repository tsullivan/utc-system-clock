// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UTCClock",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "UTCClock", path: "Sources/UTCClock")
    ]
)
