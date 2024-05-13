// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SyncUps",
  platforms: [
    .iOS(.v17),
    .macOS(.v10_15)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "AppFeature",
      targets: ["AppFeature"]
    ),
    .library(name: "Models", targets: ["Models"]),
    .library(name: "SyncUpsListFeature", targets: ["SyncUpsListFeature"]),
    .library(name: "SyncUpFormFeature", targets: ["SyncUpFormFeature"]),
    .library(name: "SyncUpDetailFeature", targets: ["SyncUpDetailFeature"]),
    .library(name: "Utils", targets: ["Utils"]),
    .library(name: "MeetingFeature", targets: ["MeetingFeature"]),
    .library(name: "RecordMeetingFeature", targets: ["RecordMeetingFeature"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.10.2"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections.git", from: "1.0.1"),
    .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.10.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "AppFeature",
      dependencies: [
        "SyncUpDetailFeature",
        "SyncUpsListFeature",
        "SyncUpFormFeature",
        "Models",
        "Utils",
        "MeetingFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .target(name: "Models", dependencies: [
      .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
      .product(name: "Tagged", package: "swift-tagged")
    ]),
    .target(name: "SyncUpsListFeature", dependencies: [
      "Models",
      "SyncUpFormFeature",
      "SyncUpDetailFeature",
      "Utils",
      "MeetingFeature",
      "RecordMeetingFeature",
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    ]),
    .target(name: "SyncUpFormFeature", dependencies: [
      "Models",
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "SyncUpDetailFeature", dependencies: [
      "Models",
      "SyncUpFormFeature",
      "Utils",
      "MeetingFeature",
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "MeetingFeature", dependencies: [
      "Models",
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "Utils", dependencies: [
    ]),
    .target(name: "RecordMeetingFeature", dependencies: [
      "Models",
      "Utils",
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .testTarget(name: "SyncUpsTests", dependencies: [
      "Models",
      "SyncUpsListFeature",
      "SyncUpFormFeature",
      "SyncUpDetailFeature",
      "Utils",
      "AppFeature",
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    ])
  ]
)
