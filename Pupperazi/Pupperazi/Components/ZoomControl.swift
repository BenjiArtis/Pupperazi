import SwiftUI

// MARK: - Zoom Control

struct ZoomControl: View {
    /// The available major zoom steps (e.g. [0.5, 1, 2, 5, 10]).
    let steps: [Double]

    /// Current zoom level — updated continuously while dragging.
    @Binding var zoom: Double

    /// Internal continuous offset driving the ruler position during drag.
    @State private var currentOffset: CGFloat = .nan

    /// Number of snap notches between each major step.
    private let notchesPerStep = 7

    /// Spacing in points between each notch.
    private let notchSpacing: CGFloat = 12

    // MARK: Derived

    private var totalNotches: Int {
        (steps.count - 1) * (notchesPerStep + 1)
    }

    private var rulerWidth: CGFloat {
        CGFloat(totalNotches) * notchSpacing
    }

    // MARK: Gesture state

    @State private var dragStartOffset: CGFloat = 0
    @State private var isDragging = false
    /// 0→1 progress for drag-active visual state, driven by DisplayLink for Canvas.
    @State private var dragProgress: CGFloat = 0
    @State private var dragProgressTarget: CGFloat = 0
    @State private var displayLink: CADisplayLink?
    @State private var animationStart: CFTimeInterval = 0
    @State private var animationFrom: CGFloat = 0
    private let animationDuration: CFTimeInterval = 0.25

    var body: some View {
        GeometryReader { geo in
            let centreX = geo.size.width / 2

            ZStack(alignment: .top) {
                // Sliding ruler — Canvas for pixel-precise positioning
                Canvas { context, size in
                    let resolvedOffset = currentOffset.isNaN ? offsetForZoom(zoom) : currentOffset
                    let originX = centreX - resolvedOffset

                    for index in 0...totalNotches {
                        let isMajor = index % (notchesPerStep + 1) == 0
                        let x = originX + CGFloat(index) * notchSpacing

                        // Skip if off-screen
                        guard x > -40 && x < size.width + 40 else { continue }

                        // Notch line — major steps lerp from minor height to full height
                        let minorHeight: CGFloat = 10
                        let majorHeight: CGFloat = 16
                        let lineHeight: CGFloat = isMajor
                            ? minorHeight + (majorHeight - minorHeight) * dragProgress
                            : minorHeight
                        let posInSegment = index % (notchesPerStep + 1)
                        let baseOpacity: Double = if isMajor {
                            1.0
                        } else if posInSegment == 4 {
                            0.75
                        } else if posInSegment == 2 || posInSegment == 6 {
                            0.5
                        } else {
                            0.25
                        }
                        let opacity = isMajor
                            ? 0.75 + (baseOpacity - 0.75) * dragProgress
                            : baseOpacity
                        let lineRect = CGRect(
                            x: x - 1,
                            y: 0,
                            width: 2,
                            height: lineHeight
                        )
                        context.fill(
                            RoundedRectangle(cornerRadius: 0.5).path(in: lineRect),
                            with: .color(AppColor.Label.tertiary.opacity(opacity))
                        )

                        // Step label — fades in/out with dragProgress
                        if isMajor, dragProgress > 0.01 {
                            let stepIndex = index / (notchesPerStep + 1)
                            if stepIndex < steps.count {
                                let segmentWidth = CGFloat(notchesPerStep + 1) * notchSpacing
                                let distFromCentre = abs(x - centreX)
                                let fadeZone = segmentWidth * 0.75
                                let proximityOpacity = min(distFromCentre / fadeZone, 1.0)
                                let labelOpacity = proximityOpacity * dragProgress

                                let label = formatStep(steps[stepIndex])
                                let text = Text(label)
                                    .font(AppFont.title.bold())
                                    .foregroundStyle(AppColor.Label.tertiary.opacity(labelOpacity))
                                let resolved = context.resolve(text)
                                let textSize = resolved.measure(in: size)
                                context.draw(
                                    resolved,
                                    at: CGPoint(x: x, y: lineHeight + 4 + textSize.height / 2),
                                    anchor: .center
                                )
                            }
                        }
                    }
                }
                .frame(height: 40)

                // Fixed centre indicator line
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColor.Fill.accent)
                    .frame(width: isDragging ? 4 : 2, height: isDragging ? 16 : 12)
                    .position(x: centreX, y: isDragging ? 8 : 4)
                    .animation(.easeInOut(duration: 0.15), value: isDragging)

                // Current zoom readout
                Text(formatZoom(zoom))
                    .font(AppFont.title.bold())
                    .foregroundStyle(AppColor.Fill.accent)
                    .position(x: centreX, y: isDragging ? 30 : 22)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: isDragging)
                    .animation(.easeOut(duration: 0.2), value: zoom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .contentShape(Rectangle())
            .mask(LinearGradient(stops: [
                Gradient.Stop(color: .clear, location: 0.0),
                Gradient.Stop(color: .black, location: 0.25),
                Gradient.Stop(color: .black, location: 0.75),
                Gradient.Stop(color: .clear, location: 1.0),
            ], startPoint: .leading, endPoint: .trailing))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            animateDragProgress(to: 1)
                        }
                        let rawOffset = dragStartOffset - value.translation.width
                        let clampedOffset = min(max(rawOffset, 0), rulerWidth)
                        currentOffset = clampedOffset
                        zoom = smoothZoom(for: clampedOffset)
                    }
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.4)) {                isDragging = false
                        }
                        animateDragProgress(to: 0)
                        // Snap to nearest notch
                        let snapped = snappedZoom(for: currentOffset)
                        zoom = snapped
                        let snappedOffset = offsetForZoom(snapped)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
                            currentOffset = snappedOffset
                        }
                        dragStartOffset = snappedOffset
                    }
            )
            .onAppear {
                let offset = offsetForZoom(zoom)
                currentOffset = offset
                dragStartOffset = offset
            }
            .onDisappear {
                stopDisplayLink()
            }
        }
        .frame(height: 56)
    }

    // MARK: - DisplayLink animation for dragProgress

    private func animateDragProgress(to target: CGFloat) {
        dragProgressTarget = target
        animationFrom = dragProgress
        animationStart = CACurrentMediaTime()
        startDisplayLink()
    }

    private func startDisplayLink() {
        stopDisplayLink()
        let link = CADisplayLink(target: DisplayLinkProxy { [self] in
            self.tickAnimation()
        }, selector: #selector(DisplayLinkProxy.tick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    private func tickAnimation() {
        let elapsed = CACurrentMediaTime() - animationStart
        let t = min(elapsed / animationDuration, 1.0)
        // Ease out cubic
        let eased = 1 - pow(1 - t, 3)
        dragProgress = animationFrom + (dragProgressTarget - animationFrom) * eased
        if t >= 1.0 {
            dragProgress = dragProgressTarget
            stopDisplayLink()
        }
    }

    // MARK: - Conversion helpers

    private func offsetForZoom(_ z: Double) -> CGFloat {
        let clamped = min(max(z, steps.first ?? 0.5), steps.last ?? 10)

        for i in 0..<(steps.count - 1) {
            if clamped <= steps[i + 1] || i == steps.count - 2 {
                let low = steps[i]
                let high = steps[i + 1]
                let fraction = (clamped - low) / (high - low)
                let segmentNotches = notchesPerStep + 1
                let startNotch = i * segmentNotches
                let notchPosition = Double(startNotch) + fraction * Double(segmentNotches)
                return CGFloat(notchPosition) * notchSpacing
            }
        }
        return 0
    }

    private func smoothZoom(for offset: CGFloat) -> Double {
        let segmentNotches = notchesPerStep + 1
        let notchPosition = offset / notchSpacing
        let rawStepIndex = Int(notchPosition) / segmentNotches
        let safeStepIndex = min(max(rawStepIndex, 0), steps.count - 2)
        let posInSegment = notchPosition - CGFloat(safeStepIndex * segmentNotches)
        let fraction = min(max(Double(posInSegment) / Double(segmentNotches), 0), 1)

        let low = steps[safeStepIndex]
        let high = steps[safeStepIndex + 1]
        return low + fraction * (high - low)
    }

    private func snappedZoom(for offset: CGFloat) -> Double {
        let notchIndex = round(offset / notchSpacing)
        let clamped = min(max(notchIndex, 0), CGFloat(totalNotches))
        let segmentNotches = notchesPerStep + 1
        let stepIndex = Int(clamped) / segmentNotches
        let notchInSegment = Int(clamped) % segmentNotches

        let safeStepIndex = min(stepIndex, steps.count - 2)
        let low = steps[safeStepIndex]
        let high = steps[safeStepIndex + 1]
        let fraction = Double(notchInSegment) / Double(segmentNotches)
        return low + fraction * (high - low)
    }

    // MARK: - Formatting

    private func formatZoom(_ value: Double) -> String {
//        if value == value.rounded() && value >= 1 {
//            return "\(Int(value))x"
//        }
        return String(format: "%.1fx", value)
    }

    private func formatStep(_ value: Double) -> String {
        if value == value.rounded() && value >= 1 {
            return "\(Int(value))x"
        }
        return String(format: "%.1fx", value)
    }
}

// MARK: - DisplayLink Helper

private class DisplayLinkProxy {
    let callback: () -> Void
    init(_ callback: @escaping () -> Void) { self.callback = callback }
    @objc func tick() { callback() }
}

// MARK: - Previews

#Preview("Zoom Control — Pro Max") {
    struct Wrapper: View {
        @State var zoom: Double = 1.0

        var body: some View {
            VStack(spacing: 24) {
                Spacer()
                ZoomControl(
                    steps: [0.5, 1, 2, 5, 10],
                    zoom: $zoom
                )
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 40)
            .background(AppColor.Background.inverse)
        }
    }
    return Wrapper()
}

#Preview("Zoom Control — Standard") {
    struct Wrapper: View {
        @State var zoom: Double = 1.0

        var body: some View {
            VStack(spacing: 24) {
                Spacer()
                ZoomControl(
                    steps: [0.5, 1, 2],
                    zoom: $zoom
                )
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 40)
            .background(AppColor.Background.inverse)
        }
    }
    return Wrapper()
}
