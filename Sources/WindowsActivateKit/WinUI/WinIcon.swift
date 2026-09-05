import AppKit
import SwiftUI

/// 统一的图标绘制。
///
/// 直接用 `Image(systemName:)` 时，SF Symbols 会按语言换成本地化字形
/// （比如 textformat 在中文环境下会画成“格式”两个字），所以这里固定取原始符号。
public struct WinIcon: View {
    private let systemName: String
    private let size: CGFloat
    private let weight: NSFont.Weight

    public init(_ systemName: String, size: CGFloat = 16, weight: NSFont.Weight = .regular) {
        self.systemName = systemName
        self.size = size
        self.weight = weight
    }

    public var body: some View {
        if let image = Self.symbol(systemName, size: size, weight: weight) {
            Image(nsImage: image)
        } else {
            Image(systemName: systemName)
                .font(.system(size: size))
        }
    }

    private static func symbol(_ name: String, size: CGFloat, weight: NSFont.Weight) -> NSImage? {
        let key = CacheKey(name: name, size: size, weight: weight.rawValue)
        if let cached = cache[key] { return cached }
        guard let base = NSImage(systemSymbolName: name, accessibilityDescription: nil) else { return nil }
        let configuration = NSImage.SymbolConfiguration(pointSize: size, weight: weight)
        guard let configured = base.withSymbolConfiguration(configuration) else { return nil }
        configured.isTemplate = true
        cache[key] = configured
        return configured
    }

    /// 重建一个符号图标约 0.09 ms，而一页设置里十来个图标会随任意状态变化整体重建，
    /// 所以按名称 + 尺寸 + 字重缓存。只在主线程的视图求值里访问。
    private static var cache: [CacheKey: NSImage] = [:]

    private struct CacheKey: Hashable {
        let name: String
        let size: CGFloat
        let weight: CGFloat
    }
}
