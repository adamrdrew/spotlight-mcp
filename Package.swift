// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "spotlight-mcp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "spotlight-mcp",
            targets: ["SpotlightMCP"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/modelcontextprotocol/swift-sdk",
            from: "0.1.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "SpotlightMCP",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "SpotlightMCPTests",
            dependencies: [
                "SpotlightMCP"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
