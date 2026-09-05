import SwiftUI

/// Windows 11 徽标：四个方块。用在标题栏和“关于”页。
public struct WinFlagBadge: View {
    private let size: CGFloat
    private let color: Color

    public init(size: CGFloat = 14, color: Color = Color(red: 0, green: 0.47, blue: 0.83)) {
        self.size = size
        self.color = color
    }

    public var body: some View {
        let gap = max(1, size * 0.1)
        let tile = (size - gap) / 2
        VStack(spacing: gap) {
            HStack(spacing: gap) {
                square(tile)
                square(tile)
            }
            HStack(spacing: gap) {
                square(tile)
                square(tile)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private func square(_ side: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: max(0.5, side * 0.08))
            .fill(color)
            .frame(width: side, height: side)
    }
}
