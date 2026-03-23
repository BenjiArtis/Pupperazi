import SwiftUI

/// A text input bar with a placeholder and a "Send" button — used in the onboarding chat.
struct ChatInputBar: View {
    @Binding var text: String
    var placeholder: String = "Type a message..."
    var isEnabled: Bool = true
    var onSend: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: $text)
                .font(AppFont.body)
                .foregroundStyle(AppColor.Label.primary)
                .focused($isFocused)
                .disabled(!isEnabled)
                .submitLabel(.send)
                .onSubmit {
                    if isEnabled && !text.trimmingCharacters(in: .whitespaces).isEmpty {
                        onSend()
                    }
                }

            ChatSendButton(isEnabled: isEnabled && !text.trimmingCharacters(in: .whitespaces).isEmpty) {
                onSend()
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 6)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(AppColor.Background.secondary)
        )
        .overlay(
            Capsule()
                .stroke(AppColor.Border.superStrong, lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("Chat Input Bar") {
    VStack {
        Spacer()
        ChatInputBar(text: .constant(""), placeholder: "Type a username...") {}
        ChatInputBar(text: .constant("BenjiArtis"), placeholder: "Type a username...") {}
    }
    .padding()
    .background(AppColor.Background.primary)
}
