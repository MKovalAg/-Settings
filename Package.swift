// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Settings",
    products: [
        .library(
            name: "Settings",
            type: .dynamic,
            targets: ["Settings"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/jrendel/SwiftKeychainWrapper", from: "4.0.1"),
        .package(url: "https://github.com/sunshinejr/SwiftyUserDefaults", from: "5.3.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver", from: "1.9.6")
    ],
    targets: [
        .target(
            name: "Settings",
            dependencies: [
                .byName(name: "SwiftKeychainWrapper"),
                .byName(name: "SwiftyUserDefaults"),
                .byName(name: "SwiftyBeaver")
            ]
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: ["Settings"],
            path: "Tests"
        ),
    ]
)
