import Foundation

/// 应用的基本信息，命令行直接运行（没有 .app 包）时也有合理取值。
public enum AppInfo {
    public static let displayName = "Windows 激活"
    public static let repository = "https://github.com/yxyyds666/Windows-Activate-for-macOS"

    public static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    public static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
