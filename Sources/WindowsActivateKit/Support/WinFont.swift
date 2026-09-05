import AppKit

/// Windows 字体的近似方案。
///
/// 装了 Office 的 Mac 通常有 Segoe UI，能拿到最接近 Windows 的字形；
/// 拿不到就退回系统字体，并为中文补一条 Microsoft YaHei → PingFang 的字形回退链。
public enum WinFont {
    private static let textFamilies = ["Segoe UI Variable Text", "Segoe UI", "Selawik", "Inter"]
    private static let displayFamilies = ["Segoe UI Variable Display", "Segoe UI", "Selawik", "Inter"]
    private static let chineseFamilies = ["Microsoft YaHei UI", "Microsoft YaHei", "PingFang SC"]

    private static let availableFamilies = Set(NSFontManager.shared.availableFontFamilies)

    /// 界面字体（Windows 11 的字号阶梯直接按 pt 使用）。
    public static func ui(size: CGFloat, weight: NSFont.Weight = .regular) -> NSFont {
        font(families: size >= 20 ? displayFamilies : textFamilies, size: size, weight: weight)
    }

    /// 水印字体：中文版 Windows 的水印用的是 Microsoft YaHei，所以中文优先。
    public static func watermark(size: CGFloat, language: ResolvedLanguage) -> NSFont {
        let families = language == .simplifiedChinese ? chineseFamilies + textFamilies : textFamilies
        return font(families: families, size: size, weight: .regular)
    }

    private static func font(families: [String], size: CGFloat, weight: NSFont.Weight) -> NSFont {
        let key = CacheKey(families: families, size: size, weight: weight.rawValue)
        if let cached = cache[key] { return cached }
        let resolved = resolve(families: families, size: size, weight: weight)
        cache[key] = resolved
        return resolved
    }

    /// 拼一次 cascadeList 描述符约 0.03 ms，而水印视图每次求值都要拿两号字，所以缓存起来。
    /// 只在主线程的视图求值里访问。
    private static var cache: [CacheKey: NSFont] = [:]

    private struct CacheKey: Hashable {
        let families: [String]
        let size: CGFloat
        let weight: CGFloat
    }

    private static func resolve(families: [String], size: CGFloat, weight: NSFont.Weight) -> NSFont {
        let base: NSFont
        if let family = families.first(where: { availableFamilies.contains($0) }),
           let matched = NSFont(descriptor: descriptor(family: family, weight: weight), size: size) {
            base = matched
        } else {
            base = NSFont.systemFont(ofSize: size, weight: weight)
        }

        let cascade = chineseFamilies
            .filter { availableFamilies.contains($0) }
            .map { NSFontDescriptor(fontAttributes: [.family: $0]) }
        guard !cascade.isEmpty else { return base }
        let descriptor = base.fontDescriptor.addingAttributes([.cascadeList: cascade])
        return NSFont(descriptor: descriptor, size: size) ?? base
    }

    private static func descriptor(family: String, weight: NSFont.Weight) -> NSFontDescriptor {
        NSFontDescriptor(fontAttributes: [
            .family: family,
            .traits: [NSFontDescriptor.TraitKey.weight: weight.rawValue]
        ])
    }
}
