// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UTCClock",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "UTCClock", path: "Sources/UTCClock"),
        .executableTarget(name: "svg2png", path: "Sources/svg2png"),
        .executableTarget(name: "makeicon", path: "Sources/makeicon"),
        .testTarget(name: "UTCClockTests", dependencies: ["UTCClock"], path: "Tests/UTCClockTests"),
    ]
)
