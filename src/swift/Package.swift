// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "cursor-agent-notifier",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "cursor-agent-notifier",
            targets: ["cursor-agent-notifier"]
        )
    ],
    targets: [
        .executableTarget(
            name: "cursor-agent-notifier",
            path: ".",
            sources: ["main.swift"]
        )
    ]
) 