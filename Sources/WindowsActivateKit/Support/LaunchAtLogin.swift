import ServiceManagement

/// 开机自启。SMAppService 只认签名过的 .app，命令行直接跑 SwiftPM 产物时不可用。
public enum LaunchAtLogin {
    public static var isAvailable: Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }

    public static var isEnabled: Bool {
        guard isAvailable else { return false }
        return SMAppService.mainApp.status == .enabled
    }

    /// register / unregister 要跨进程走 launchd，别放在 SwiftUI 的视图更新里同步执行，
    /// 这里挪到后台线程，调用方拿到结果后再回主线程刷状态。
    public static func setInBackground(_ enabled: Bool) async throws {
        try await Task.detached(priority: .userInitiated) {
            try set(enabled)
        }.value
    }

    public static func set(_ enabled: Bool) throws {
        guard isAvailable else { throw LaunchAtLoginError.notBundled }
        if enabled {
            try SMAppService.mainApp.register()
        } else if SMAppService.mainApp.status == .enabled {
            try SMAppService.mainApp.unregister()
        }
    }
}

public enum LaunchAtLoginError: LocalizedError {
    case notBundled

    public var errorDescription: String? {
        "需要先用 Scripts/build-app.sh 打包成 .app 并放进“应用程序”，才能设置开机启动。"
    }
}
