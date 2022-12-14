// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BytePattern",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BytePattern",
            targets: ["BytePattern"]
        ),
        .library(
            name: "XCTAssertBytesEqual",
            targets: ["XCTAssertBytesEqual"]
        ),
        .library(
            name: "BytesMutation",
            targets: ["BytesMutation"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BytePattern",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]
        ),
        .target(
            name: "XCTAssertBytesEqual",
            dependencies: [
                "BytePattern"
            ]
        ),
        .target(
            name: "BytesMutation",
            dependencies: [
                "BytePattern",
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]
        ),
        .testTarget(
            name: "BytePatternTests",
            dependencies: [
                "XCTAssertBytesEqual",
                "BytesMutation"
            ]
        ),
    ]
)
