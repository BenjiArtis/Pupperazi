import SwiftUI

/// A circular avatar for the chat onboarding — supports an image or a text initial fallback.
struct ChatAvatar: View {
    var image: Image?
    var initial: String = ""
    var size: CGFloat = 40
    var borderColor: Color = AppColor.Border.superStrong
    var backgroundColor: Color = AppColor.Fill.accent

    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    backgroundColor

                    Text(initial.prefix(1).uppercased())
                        .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

// MARK: - Convenience

extension ChatAvatar {
    /// Pawrez Hilton's avatar — uses the bundled profile picture.
    static func pawrez(size: CGFloat = 40) -> ChatAvatar {
        ChatAvatar(
            image: Image("pawrezHilton_profilePicture"),
            size: size,
            borderColor: AppColor.Border.superStrong,
            backgroundColor: PrimativeColor.black
        )
    }

    /// Current user's avatar — initial-based fallback.
    static func user(_ name: String, size: CGFloat = 40) -> ChatAvatar {
        ChatAvatar(
            initial: name,
            size: size,
            borderColor: AppColor.Border.superStrong,
            backgroundColor: AppColor.Fill.accent
        )
    }
}

// MARK: - Preview

#Preview("Chat Avatars") {
    HStack(spacing: 16) {
        ChatAvatar.pawrez()
        ChatAvatar.pawrez(size: 56)
        ChatAvatar.user("BenjiArtis")
        ChatAvatar.user("BenjiArtis", size: 56)
    }
    .padding()
    .background(AppColor.Background.primary)
}
