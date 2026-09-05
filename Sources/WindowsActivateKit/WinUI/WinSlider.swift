import SwiftUI

/// WinUI 的滑块：4pt 轨道加 20pt 圆形滑块，内圈会随悬停和拖拽变化。
public struct WinSlider: View {
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double?
    private let valueLabel: ((Double) -> String)?

    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false
    @State private var isDragging = false

    private let thumbDiameter: CGFloat = 20
    private let trackHeight: CGFloat = 4

    public init(
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double? = nil,
        valueLabel: ((Double) -> String)? = nil
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.valueLabel = valueLabel
    }

    public var body: some View {
        HStack(spacing: 14) {
            track
            if let valueLabel {
                Text(valueLabel(value))
                    .font(WinText.body)
                    .monospacedDigit()
                    .foregroundStyle(isEnabled ? WinColor.textSecondary : WinColor.textDisabled)
                    .frame(width: 46, alignment: .trailing)
            }
        }
    }

    private var track: some View {
        GeometryReader { proxy in
            let travel = max(1, proxy.size.width - thumbDiameter)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(isEnabled ? WinColor.controlStrongStroke : WinColor.controlFillDisabled)
                    .frame(height: trackHeight)
                Capsule()
                    .fill(isEnabled ? WinColor.accent : WinColor.accentDisabled)
                    .frame(width: thumbDiameter / 2 + travel * fraction, height: trackHeight)
                thumb.offset(x: travel * fraction)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        isDragging = true
                        commit(x: gesture.location.x, travel: travel)
                    }
                    .onEnded { _ in isDragging = false }
            )
        }
        .frame(height: WinMetrics.controlHeight)
        .onHover { isHovering = $0 }
        .accessibilityElement()
        .accessibilityValue(valueLabel?(value) ?? String(format: "%.2f", value))
        .accessibilityAdjustableAction { direction in
            let delta = step ?? (range.upperBound - range.lowerBound) / 20
            switch direction {
            case .increment: value = min(range.upperBound, value + delta)
            case .decrement: value = max(range.lowerBound, value - delta)
            @unknown default: break
            }
        }
    }

    private var thumb: some View {
        Circle()
            .fill(WinColor.controlFillInputActive)
            .frame(width: thumbDiameter, height: thumbDiameter)
            .overlay(Circle().strokeBorder(WinColor.controlStrongStroke.opacity(0.55), lineWidth: 1))
            .overlay(
                Circle()
                    .fill(isEnabled ? WinColor.accent : WinColor.accentDisabled)
                    .frame(width: innerDiameter, height: innerDiameter)
            )
            .shadow(color: .black.opacity(0.12), radius: 1.5, y: 0.5)
            .animation(.easeOut(duration: 0.1), value: innerDiameter)
    }

    private var innerDiameter: CGFloat {
        if isDragging { return 10 }
        return isHovering ? 14 : 12
    }

    private var fraction: CGFloat {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return CGFloat(((value - range.lowerBound) / span).clamped(to: 0...1))
    }

    private func commit(x: CGFloat, travel: CGFloat) {
        let ratio = Double(((x - thumbDiameter / 2) / travel).clamped(to: 0...1))
        var next = range.lowerBound + ratio * (range.upperBound - range.lowerBound)
        if let step, step > 0 {
            next = (next / step).rounded() * step
        }
        value = next.clamped(to: range)
    }
}
