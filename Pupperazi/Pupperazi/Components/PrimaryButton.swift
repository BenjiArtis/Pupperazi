import SwiftUI

/// Orange pill-shaped primary action button.
///
/// Set `fullWidth` to `true` to make the button expand to fill available width.
struct PrimaryButton: View {
    let title: String
    var fullWidth: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.title.bold())
                .foregroundStyle(AppColor.Label.inverse)
                .lineLimit(1)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .background(
                    Capsule()
                        .fill(AppColor.Fill.accent)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Primary Button") {
    ZStack {
        AppColor.Background.inverse.ignoresSafeArea()

        VStack(spacing: 20) {
            PrimaryButton(title: "Yeah, let's go!") {}
            PrimaryButton(title: "Continue") {}
            PrimaryButton(title: "Save") {}
        }
    }
}
