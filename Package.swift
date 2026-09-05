// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WindowsActivate",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "WindowsActivate", targets: ["WindowsActivate"])
    ],
    targets: [
        .target(
            name: "WindowsActivateKit",
            path: "Sources/WindowsActivateKit",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .executableTarget(
            name: "WindowsActivate",
            dependencies: ["WindowsActivateKit"],
            path: "Sources/WindowsActivate",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "WindowsActivateKitTests",
            dependencies: ["WindowsActivateKit"],
            path: "Tests/WindowsActivateKitTests",
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
