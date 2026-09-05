import AppKit
import SwiftUI

private struct WinUIOffscreenKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// 离屏渲染（生成截图）时为 true：此时用纯色替换毛玻璃，否则会渲染成透明。
    public var winUIRendersOffscreen: Bool {
        get { self[WinUIOffscreenKey.self] }
        set { self[WinUIOffscreenKey.self] = newValue }
    }
}

/// 近似 Windows 11 的 Mica 背景：桌面模糊 + 一层主色调。
public struct MicaBackdrop: View {
    @Environment(\.winUIRendersOffscreen) private var rendersOffscreen

    public init() {}

    public var body: some View {
        ZStack {
            if rendersOffscreen {
                WinColor.solidBackgroundBase
            } else {
                DesktopBlur()
                WinColor.solidBackgroundBase.opacity(0.55)
            }
        }
        .ignoresSafeArea()
    }
}

private struct DesktopBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .underWindowBackground
        view.blendingMode = .behindWindow
        view.state = .active
        view.isEmphasized = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
