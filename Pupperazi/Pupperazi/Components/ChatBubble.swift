import SwiftUI

/// A single chat message bubble — can be a "pawrez" (left) or "user" (right) variant.
struct ChatBubble: View {
    let text: String
    var sender: ChatSender = .pawrez

    var body: some View {
        Text(text)
            .font(AppFont.body.bold())
            .foregroundStyle(sender.textColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(sender.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(sender.borderColor, lineWidth: 1)
            )
    }
}

/// A chat bubble that holds an image (e.g. user's profile photo during onboarding).
struct ChatImageBubble: View {
    let image: Image
    var borderColor: Color = PrimativeColor.blue

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 160, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}

/// A pill chip showing the user's chosen username.
struct ChatUsernameChip: View {
    let username: String

    var body: some View {
        Text(username)
            .font(AppFont.title.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(AppColor.Fill.accent)
            )
    }
}

// MARK: - Chat Sender

enum ChatSender {
    case pawrez
    case user

    var textColor: Color {
        switch self {
        case .pawrez: return AppColor.Label.primary
        case .user: return AppColor.Label.primary
        }
    }

    var backgroundColor: Color {
        switch self {
        case .pawrez: return AppColor.Background.secondary
        case .user: return AppColor.Background.secondary
        }
    }

    var borderColor: Color {
        switch self {
        case .pawrez: return AppColor.Border.superStrong
        case .user: return AppColor.Border.superStrong
        }
    }
}

// MARK: - Preview

#Preview("Chat Bubble Atoms") {
    VStack(spacing: 20) {
        ChatBubble(text: "So. You want to be a Pupperazi?", sender: .pawrez)
        ChatBubble(text: "I've seen a lot of hopefuls walk through that door.", sender: .pawrez)
        ChatUsernameChip(username: "BenjiArtis")
        ChatImageBubble(image: Image(systemName: "person.fill"))
    }
    .padding()
    .background(AppColor.Background.primary)
}
