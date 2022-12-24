// swift-tools-version: 5.5

import PackageDescription

let package = Package(
  name: "JSONAttachment",
  products: [
    .library(
      name: "JSONAttachment",
      targets: ["JSONAttachment"]),
  ],
  targets: [
    .target(
      name: "JSONAttachment",
      dependencies: []),
    .testTarget(
      name: "JSONAttachmentTests",
      dependencies: ["JSONAttachment"]),
  ]
)
