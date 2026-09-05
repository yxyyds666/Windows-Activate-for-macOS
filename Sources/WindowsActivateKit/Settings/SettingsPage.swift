import SwiftUI

/// 设置窗口的分页。
public enum SettingsPage: String, CaseIterable, Identifiable {
    case general
    case activation
    case watermark
    case position
    case about

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .general: return "常规"
        case .activation: return "激活"
        case .watermark: return "水印"
        case .position: return "位置"
        case .about: return "关于"
        }
    }

    var systemImage: String {
        switch self {
        case .general: return "gearshape"
        case .activation: return "key"
        case .watermark: return "drop"
        case .position: return "arrow.up.left.and.arrow.down.right"
        case .about: return "info.circle"
        }
    }

    public static var navigationItems: [WinNavigationItem] {
        allCases.map { WinNavigationItem(id: $0.id, title: $0.title, systemImage: $0.systemImage) }
    }
}
