import Combine
import Foundation

/// 设置的读写与广播中心：界面改动会立即落盘，并驱动水印覆盖层刷新。
@MainActor
public final class SettingsStore: ObservableObject {
    @Published public var settings: WatermarkSettings

    private let defaults: UserDefaults
    private let storageKey: String
    private var persistence: AnyCancellable?

    public init(defaults: UserDefaults = .standard, storageKey: String = "watermarkSettings.v1") {
        self.defaults = defaults
        self.storageKey = storageKey
        self.settings = Self.decode(from: defaults, key: storageKey) ?? WatermarkSettings()
        // @Published 在 willSet 时发布，因此这里保存的是闭包参数而不是 self.settings。
        persistence = $settings
            .dropFirst()
            .sink { [weak self] newValue in self?.write(newValue) }
    }

    /// 切到“自定义文案”时先把当前预设的文字填进去，避免输入框一片空白。
    public func selectPreset(_ preset: WatermarkPreset) {
        var updated = settings
        if preset == .custom {
            let current = settings.resolvedText()
            if updated.customTitle.isEmpty { updated.customTitle = current.title }
            if updated.customSubtitle.isEmpty { updated.customSubtitle = current.subtitle }
        }
        updated.preset = preset
        settings = updated
    }

    public func reset() {
        settings = WatermarkSettings()
    }

    private func write(_ value: WatermarkSettings) {
        guard let data = try? JSONEncoder().encode(value.sanitized()) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private static func decode(from defaults: UserDefaults, key: String) -> WatermarkSettings? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return (try? JSONDecoder().decode(WatermarkSettings.self, from: data))?.sanitized()
    }
}
