import Foundation

/// 卡密激活状态。
///
/// 这里不做任何校验：随便输什么都能“激活成功”，这正是这个玩笑项目想还原的荒诞感。
public struct ActivationState: Codable, Equatable, Sendable {
    public var isActivated: Bool
    public var productKey: String
    public var activatedAt: Date?

    public init(isActivated: Bool = false, productKey: String = "", activatedAt: Date? = nil) {
        self.isActivated = isActivated
        self.productKey = productKey
        self.activatedAt = activatedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isActivated = ((try? container.decodeIfPresent(Bool.self, forKey: .isActivated)) ?? nil) ?? false
        self.productKey = ((try? container.decodeIfPresent(String.self, forKey: .productKey)) ?? nil) ?? ""
        self.activatedAt = (try? container.decodeIfPresent(Date.self, forKey: .activatedAt)) ?? nil
    }

    /// 激活时间的可读形式。
    public var activatedAtDescription: String? {
        guard let activatedAt else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: activatedAt)
    }
}

/// 产品密钥的显示格式：照 Windows 的样子排成 5 段、每段 5 位。
public enum ProductKey {
    public static let groupCount = 5
    public static let groupLength = 5
    public static let placeholder = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"

    /// 整理用户输入：转大写、去掉空白与连字符、每 5 位插入一个连字符、最多 25 位。
    /// 有意不限制字符集——输中文、输符号都照收，因为怎么输都能激活。
    public static func format(_ raw: String) -> String {
        let cleaned = raw.uppercased().filter { !$0.isWhitespace && $0 != "-" }
        let characters = Array(cleaned.prefix(groupCount * groupLength))
        guard !characters.isEmpty else { return "" }
        return stride(from: 0, to: characters.count, by: groupLength)
            .map { String(characters[$0..<min($0 + groupLength, characters.count)]) }
            .joined(separator: "-")
    }

    /// 是否填满了 25 位。只用来给输入框提示，不影响能不能激活。
    public static func isComplete(_ raw: String) -> Bool {
        raw.uppercased().filter { !$0.isWhitespace && $0 != "-" }.count >= groupCount * groupLength
    }
}
