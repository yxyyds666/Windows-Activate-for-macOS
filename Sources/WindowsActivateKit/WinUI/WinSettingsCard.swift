import SwiftUI

/// Windows 11 “设置”里的那种设置行：左侧图标 + 标题说明，右侧或下方放控件。
public struct WinSettingsCard<Control: View>: View {
    public enum ControlPlacement {
        case trailing
        case below
    }

    private let systemImage: String?
    private let title: String
    private let subtitle: String?
    private let placement: ControlPlacement
    private let control: Control

    public init(
        systemImage: String? = nil,
        title: String,
        subtitle: String? = nil,
        placement: ControlPlacement = .trailing,
        @ViewBuilder control: () -> Control
    ) {
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
        self.placement = placement
        self.control = control()
    }

    public var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 60)
            .background(shape.fill(WinColor.cardBackground))
            .overlay(shape.strokeBorder(WinColor.cardStroke, lineWidth: 1))
    }

    @ViewBuilder
    private var content: some View {
        switch placement {
        case .trailing:
            HStack(spacing: 16) {
                header
                Spacer(minLength: 12)
                control
            }
        case .below:
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    header
                    Spacer(minLength: 12)
                }
                control
            }
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            if let systemImage {
                WinIcon(systemImage, size: 16)
                    .foregroundStyle(WinColor.textSecondary)
                    .frame(width: 20, height: 20)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(WinText.body)
                    .foregroundStyle(WinColor.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(WinText.caption)
                        .foregroundStyle(WinColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: WinMetrics.controlCornerRadius)
    }
}

/// 设置分组的小标题。
public struct WinSectionHeader: View {
    private let title: String

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(WinText.bodyStrong)
            .foregroundStyle(WinColor.textPrimary)
            .padding(.top, 10)
            .padding(.bottom, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
