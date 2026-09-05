import AppKit
import SwiftUI

struct AboutPage: View {
    @ObservedObject var store: SettingsStore

    var body: some View {
        VStack(spacing: 4) {
            identityCard

            WinSettingsCard(
                systemImage: "exclamationmark.circle",
                title: "这是一个玩笑项目",
                subtitle: "它只是在桌面上画了一层透明覆盖窗口，把 Windows 的未激活水印搬到 macOS 上。不修改系统、不碰任何激活或破解相关的东西。"
            ) {
                EmptyView()
            }

            WinSettingsCard(
                systemImage: "keyboard",
                title: "菜单栏图标",
                subtitle: "关掉设置窗口后，从菜单栏的四格图标再打开。菜单栏应用退到后台时没有菜单栏，所以 ⌘, 只在窗口已经打开时有效。"
            ) {
                EmptyView()
            }

            WinSettingsCard(
                systemImage: "link",
                title: "项目地址",
                subtitle: AppInfo.repository
            ) {
                Button("打开") {
                    if let url = URL(string: AppInfo.repository) {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(WinButtonStyle())
            }

            WinSectionHeader("重置与退出")

            WinSettingsCard(
                systemImage: "arrow.counterclockwise",
                title: "恢复默认设置",
                subtitle: "文案、位置、透明度都回到初始状态"
            ) {
                Button("恢复默认") { store.reset() }
                    .buttonStyle(WinButtonStyle())
            }

            WinSettingsCard(
                systemImage: "xmark.circle",
                title: "退出 Windows 激活",
                subtitle: "水印会一起消失"
            ) {
                Button("退出") { NSApp.terminate(nil) }
                    .buttonStyle(WinButtonStyle())
            }

            Text("自定义许可协议 · 允许非商业二次分发 · 使用 Swift + SwiftUI 编写")
                .font(WinText.caption)
                .foregroundStyle(WinColor.textTertiary)
                .padding(.top, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var identityCard: some View {
        HStack(spacing: 16) {
            WinFlagBadge(size: 40)
            VStack(alignment: .leading, spacing: 3) {
                Text(AppInfo.displayName)
                    .font(WinText.bodyLarge)
                    .foregroundStyle(WinColor.textPrimary)
                Text("版本 \(AppInfo.version)（\(AppInfo.build)）")
                    .font(WinText.caption)
                    .foregroundStyle(WinColor.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(shape.fill(WinColor.cardBackground))
        .overlay(shape.strokeBorder(WinColor.cardStroke, lineWidth: 1))
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: WinMetrics.controlCornerRadius)
    }
}
