import AppKit

/// 启动入口：正常启动跑常驻应用，带 `--snapshot <目录>` 则只生成界面截图。
@MainActor
public enum WindowsActivateBootstrap {
    private static var controller: AppController?

    public static func run(arguments: [String] = []) {
        if let index = arguments.firstIndex(of: "--snapshot") {
            let directory = arguments.count > index + 1 ? arguments[index + 1] : "Snapshots"
            renderSnapshots(directory: directory)
            return
        }

        let app = NSApplication.shared
        let controller = AppController()
        Self.controller = controller
        app.delegate = controller
        app.run()
    }

    private static func renderSnapshots(directory: String) {
        _ = NSApplication.shared
        NSApp.setActivationPolicy(.prohibited)
        do {
            let files = try SnapshotRenderer.renderAll(
                into: URL(fileURLWithPath: directory, isDirectory: true)
            )
            files.forEach { print($0.path) }
        } catch {
            FileHandle.standardError.write(Data("快照生成失败：\(error)\n".utf8))
            exit(1)
        }
    }
}
