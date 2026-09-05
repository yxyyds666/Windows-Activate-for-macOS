import ServiceManagement

/// 开机自启。SMAppService 只认签名过的 .app，命令行直接跑 SwiftPM 产物时不可用。
@MainActor
public enum LaunchAtLogin {
    public static var isAvailable: Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }

    public static var isEnabled: Bool {
        guard isAvailable else { return false }
        return SMAppService.mainApp.status == .enabled
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
