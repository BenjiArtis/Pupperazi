import SwiftUI

/// An orange capsule "Send" button with an arrow-up icon.
struct ChatSendButton: View {
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .bold))

                Text("Send")
                    .font(AppFont.title.bold())
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isEnabled ? AppColor.Fill.accent : AppColor.Fill.accent.opacity(0.4))
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

// MARK: - Preview

#Preview("Send Button") {
    VStack(spacing: 16) {
        ChatSendButton(isEnabled: true) {}
        ChatSendButton(isEnabled: false) {}
    }
    .padding()
    .background(AppColor.Background.primary)
}
