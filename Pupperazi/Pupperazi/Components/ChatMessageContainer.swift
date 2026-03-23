import SwiftUI

/// A group of message bubbles from Pawrez Hilton — name label on top,
/// bubbles left-aligned, avatar on the bottom-left of the last bubble.
struct PawrezMessageContainer<Content: View>: View {
    var showAvatar: Bool = true
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Sender name
            Text("Pawrez Hilton")
                .font(AppFont.caption.bold())
                .foregroundStyle(AppColor.Label.primary)
                .padding(.leading, showAvatar ? 52 : 0)

            // Bubbles + avatar
            HStack(alignment: .bottom, spacing: 8) {
                if showAvatar {
                    ChatAvatar.pawrez()
                }

                VStack(alignment: .leading, spacing: 4) {
                    content()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A group of message content from the user — name label on top,
/// content right-aligned, avatar on the bottom-right.
struct UserMessageContainer<Content: View>: View {
    var username: String = ""
    var showAvatar: Bool = true
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Sender name
            if !username.isEmpty {
                Text(username)
                    .font(AppFont.caption.bold())
                    .foregroundStyle(AppColor.Label.primary)
                    .padding(.trailing, showAvatar ? 52 : 0)
            }

            // Content + avatar
            HStack(alignment: .bottom, spacing: 8) {
                VStack(alignment: .trailing, spacing: 4) {
                    content()
                }

                if showAvatar {
                    ChatAvatar.user(username)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

// MARK: - Preview

#Preview("Pawrez Message Container") {
    VStack(spacing: 24) {
        PawrezMessageContainer {
            ChatBubble(text: "So. You want to be a Pupperazi?", sender: .pawrez)
            ChatBubble(
                text: "I've seen a lot of hopefuls walk through that door. Most of them couldn't spot a Dachshund from a Corgi.",
                sender: .pawrez
            )
            ChatBubble(
                text: "Let's see if you're different. What do I call you? And make it good.",
                sender: .pawrez
            )
        }
    }
    .padding()
    .background(AppColor.Background.primary)
}

#Preview("User Message Container") {
    VStack(spacing: 24) {
        UserMessageContainer(username: "BenjiArtis") {
            ChatUsernameChip(username: "BenjiArtis")
        }

        UserMessageContainer(username: "BenjiArtis") {
            ChatImageBubble(image: Image(systemName: "person.fill"))
        }
    }
    .padding()
    .background(AppColor.Background.primary)
}
