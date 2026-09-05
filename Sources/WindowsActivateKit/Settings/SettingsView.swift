import SwiftUI

/// 设置窗口的根视图：顶部是 Windows 式标题栏，左侧导航，右侧内容区。
public struct SettingsView: View {
    @ObservedObject private var store: SettingsStore

    private let showsInlineCaptionButtons: Bool
    private let isZoomed: Bool
    private let captionAction: (WinCaptionAction) -> Void

    @State private var selection: String
    @Environment(\.winUIRendersOffscreen) private var rendersOffscreen

    public init(
        store: SettingsStore,
        initialPage: SettingsPage = .general,
        showsInlineCaptionButtons: Bool = false,
        isZoomed: Bool = false,
        captionAction: @escaping (WinCaptionAction) -> Void = { _ in }
    ) {
        self.store = store
        self.showsInlineCaptionButtons = showsInlineCaptionButtons
        self.isZoomed = isZoomed
        self.captionAction = captionAction
        self._selection = State(initialValue: initialPage.id)
    }

    public var body: some View {
        ZStack {
            MicaBackdrop()
            VStack(spacing: 0) {
                captionBar
                HStack(alignment: .top, spacing: 0) {
                    WinNavigationPane(items: SettingsPage.navigationItems, selection: $selection)
                    contentArea
                }
            }
        }
        .frame(minWidth: 720, minHeight: 520)
    }

    /// 标题栏：真实窗口里按钮由标题栏附件绘制，这里只占位；离屏截图时直接画出来。
    private var captionBar: some View {
        HStack(spacing: 0) {
            if showsInlineCaptionButtons {
                WinCaptionButtons(isZoomed: isZoomed, action: captionAction)
            } else {
                Color.clear.frame(width: 3 * WinMetrics.captionButtonWidth, height: WinMetrics.captionBarHeight)
            }
            WinFlagBadge(size: 12)
                .padding(.leading, 12)
            Text("Windows 激活")
                .font(WinText.caption)
                .foregroundStyle(WinColor.textPrimary)
                .padding(.leading, 8)
            Spacer(minLength: 0)
        }
        .frame(height: WinMetrics.captionBarHeight)
    }

    private var contentArea: some View {
        scroller
            .background(WinColor.layerFill)
            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: WinMetrics.overlayCornerRadius)))
            .overlay(
                UnevenRoundedRectangle(cornerRadii: .init(topLeading: WinMetrics.overlayCornerRadius))
                    .strokeBorder(WinColor.cardStroke, lineWidth: 1)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// ImageRenderer 不会渲染 ScrollView 里的内容，所以生成截图时换成普通竖排。
    @ViewBuilder
    private var scroller: some View {
        if rendersOffscreen {
            pageContent
                .frame(maxHeight: .infinity, alignment: .top)
        } else {
            ScrollView { pageContent }
        }
    }

    private var pageContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(currentPage.title)
                .font(WinText.subtitle)
                .foregroundStyle(WinColor.textPrimary)
                .padding(.bottom, 10)
            page
        }
        .padding(.horizontal, 26)
        .padding(.top, 20)
        .padding(.bottom, 26)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var currentPage: SettingsPage {
        SettingsPage(rawValue: selection) ?? .general
    }

    @ViewBuilder
    private var page: some View {
        switch currentPage {
        case .general: GeneralPage(store: store)
        case .watermark: WatermarkPage(store: store)
        case .position: PositionPage(store: store)
        case .about: AboutPage(store: store)
        }
    }
}
