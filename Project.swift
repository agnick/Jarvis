import ProjectDescription

let project = Project(
    name: "Jarvis",
    targets: [
        .target(
            name: "Jarvis",
            destinations: .macOS,
            product: .app,
            bundleId: "dev.tuist.Jarvis",
            infoPlist: .default,
            buildableFolders: [
                "Jarvis/Sources",
                "Jarvis/Resources",
            ],
            dependencies: []
        ),
        .target(
            name: "JarvisTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "dev.tuist.JarvisTests",
            infoPlist: .default,
            buildableFolders: [
                "Jarvis/Tests"
            ],
            dependencies: [.target(name: "Jarvis")]
        ),
    ]
)
