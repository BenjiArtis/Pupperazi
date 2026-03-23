import SwiftUI

/// A stepped navigation bar with back/next buttons and step indicators.
///
/// Shows the current progress through a multi-step flow. On the first step,
/// the back button is hidden. On the last step, the indicators hide and the
/// action button expands to full width with a confirmation label.
struct SteppedNavigation: View {
    let totalSteps: Int
    @Binding var currentStep: Int
    var doneLabel: String = "Done"
    var onBack: (() -> Void)?
    var onNext: (() -> Void)?
    var onDone: (() -> Void)?

    private var isFirstStep: Bool { currentStep == 1 }
    private var isLastStep: Bool { currentStep == totalSteps }

    var body: some View {
        HStack(spacing: 16) {
            // Back button
            Button {
                if !isFirstStep {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        currentStep -= 1
                    }
                    onBack?()
                }
            } label: {
                Text("Back")
                    .font(AppFont.title.bold())
                    .foregroundStyle(AppColor.Label.primary)
            }
            .buttonStyle(.plain)
            .frame(width: 100)
            .opacity(isFirstStep ? 0 : 1)

            if !isLastStep {
                // Step indicators
                StepIndicators(totalSteps: totalSteps, currentStep: currentStep)

                // Next button
                PrimaryButton(title: "Next") {
                    if !isLastStep {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            currentStep += 1
                        }
                        onNext?()
                    }
                }
                .frame(width: 100)
            } else {
                // Done button — fills remaining space
                PrimaryButton(title: doneLabel, fullWidth: true) {
                    onDone?()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isLastStep)
    }
}

// MARK: - Step Indicators

/// Horizontal row of rounded pill indicators showing progress.
struct StepIndicators: View {
    let totalSteps: Int
    let currentStep: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step == currentStep ? AppColor.Fill.accent : AppColor.Border.default)
                    .frame(height: 4)
            }
        }
    }
}

// MARK: - Preview

#Preview("Stepped Navigation") {
    VStack(spacing: 0) {
        Spacer()

        SteppedNavigationPreview()
    }
    .background(AppColor.Background.primary.ignoresSafeArea())
}

private struct SteppedNavigationPreview: View {
    @State private var step = 1

    var body: some View {
        VStack(spacing: 24) {
            Text("Step \(step) of 4")
                .font(AppFont.title)
                .foregroundStyle(AppColor.Label.primary)

            SteppedNavigation(
                totalSteps: 4,
                currentStep: $step,
                onDone: { step = 1 }
            )
        }
    }
}
