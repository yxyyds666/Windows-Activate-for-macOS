import AppKit
import SwiftUI

/// 管理每块屏幕上的水印窗口：屏幕增减、切换桌面空间、设置变化时都会重新贴一次。
@MainActor
public final class WatermarkOverlayController {
    private struct Overlay {
        let window: WatermarkWindow
        let hosting: NSHostingView<WatermarkView>
    }

    private var overlays: [Overlay] = []
    private var settings = WatermarkSettings()
    private var observers: [(center: NotificationCenter, token: NSObjectProtocol)] = []

    public init() {
        observeEnvironment()
    }

    deinit {
        observers.forEach { $0.center.removeObserver($0.token) }
    }

    /// 应用一份新的设置并立即刷新所有屏幕上的水印。
    public func apply(_ settings: WatermarkSettings) {
        self.settings = settings.sanitized()
        refresh()
    }

    private func refresh() {
        let screens = targetScreens()
        guard settings.isEnabled, !screens.isEmpty else {
            teardown()
            return
        }

        while overlays.count < screens.count { overlays.append(makeOverlay()) }
        while overlays.count > screens.count {
            overlays.removeLast().window.orderOut(nil)
        }
        for (overlay, screen) in zip(overlays, screens) {
            update(overlay, on: screen)
        }
    }

    private func makeOverlay() -> Overlay {
        let hosting = NSHostingView(rootView: WatermarkView(text: settings.resolvedText(), settings: settings))
        hosting.sizingOptions = [.intrinsicContentSize]
        let window = WatermarkWindow()
        window.contentView = hosting
        return Overlay(window: window, hosting: hosting)
    }

    private func update(_ overlay: Overlay, on screen: NSScreen) {
        overlay.hosting.rootView = WatermarkView(text: settings.resolvedText(), settings: settings)
        overlay.hosting.layoutSubtreeIfNeeded()

        let inset = WatermarkView.shadowInset(for: settings)
        let anchor = settings.avoidsDockAndMenuBar ? screen.visibleFrame : screen.frame
        let frame = WatermarkGeometry.frame(
            contentSize: overlay.hosting.fittingSize,
            anchor: anchor,
            corner: settings.corner,
            horizontalMargin: max(0, CGFloat(settings.horizontalMargin) - inset),
            verticalMargin: max(0, CGFloat(settings.verticalMargin) - inset)
        )

        overlay.window.level = windowLevel(for: settings.overlayLevel)
        overlay.window.setFrame(frame, display: true)
        overlay.window.orderFrontRegardless()
    }

    private func windowLevel(for level: OverlayLevel) -> NSWindow.Level {
        switch level {
        case .aboveEverything:
            // 屏保层级：全屏应用、程序坞、菜单栏都盖不住它。
            return .screenSaver
        case .floating:
            return .floating
        case .desktop:
            return NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)
        }
    }

    private func targetScreens() -> [NSScreen] {
        guard settings.showsOnAllDisplays else {
            return NSScreen.screens.first.map { [$0] } ?? []
        }
        return NSScreen.screens
    }

    private func teardown() {
        overlays.forEach { $0.window.orderOut(nil) }
        overlays.removeAll()
    }

    private func bringToFront() {
        overlays.forEach { $0.window.orderFrontRegardless() }
    }

    private func observeEnvironment() {
        let screenChanges = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
        observers.append((NotificationCenter.default, screenChanges))

        let workspaceCenter = NSWorkspace.shared.notificationCenter
        let spaceChanges = workspaceCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.bringToFront() }
        }
        observers.append((workspaceCenter, spaceChanges))
    }
}
