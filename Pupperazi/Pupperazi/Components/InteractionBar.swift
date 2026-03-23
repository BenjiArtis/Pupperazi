import SwiftUI

// MARK: - Interaction Bar

/// Horizontal bar with boop, comments, treats and "+ New" treat button.
/// Sits below a post cell in the feed.
struct InteractionBar: View {
    @Binding var isBooped: Bool
    let boopCount: Int
    let commentCount: Int
    let treats: [Treat]
    var onComment: () -> Void = {}
    var onNewTreat: () -> Void = {}

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                // Boop button
                BoopButton(isBooped: $isBooped, count: boopCount)

                Divider()
                    .frame(height: 24)
                    .padding(.horizontal, 8)

                // Comments button
                CommentButton(count: commentCount, action: onComment)

                // Treats
                ForEach(treats) { treat in
                    TreatBadge(treat: treat)
                        .padding(.leading, 8)
                }

                // + New treat
                NewTreatButton(action: onNewTreat)
                    .padding(.leading, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Boop Button

struct BoopButton: View {
    @Binding var isBooped: Bool
    let count: Int

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isBooped.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 16, weight: .bold))

                Text("\(count) BOOPS")
                    .font(AppFont.caption.bold())
            }
            .foregroundStyle(isBooped ? AppColor.Fill.accent : AppColor.Label.primary)
            .padding(.horizontal, 14)
            .frame(height: 40)
            .background(AppColor.Background.secondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isBooped ? AppColor.Fill.accent : AppColor.Border.superStrong, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isBooped ? 1.0 : 1.0) // anchor for animation
    }
}

// MARK: - Comment Button

struct CommentButton: View {
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(count) Comments")
                .font(AppFont.caption.bold())
                .foregroundStyle(AppColor.Label.primary)
                .padding(.horizontal, 14)
                .frame(height: 40)
                .background(AppColor.Background.secondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppColor.Border.superStrong, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Treat Model

struct Treat: Identifiable, Hashable {
    let id: String
    let emoji: String
    var count: Int

    static let pat = Treat(id: "pat", emoji: "🤚", count: 0)
    static let bone = Treat(id: "bone", emoji: "🦴", count: 0)
    static let love = Treat(id: "love", emoji: "❤️", count: 0)
    static let ball = Treat(id: "ball", emoji: "🎾", count: 0)
    static let treat = Treat(id: "treat", emoji: "🦮", count: 0)
}

// MARK: - Treat Badge

struct TreatBadge: View {
    let treat: Treat

    var body: some View {
        HStack(spacing: 4) {
            Text(treat.emoji)
                .font(.system(size: 14))

            if treat.count > 0 {
                Text("\(treat.count)")
                    .font(AppFont.caption.bold())
                    .foregroundStyle(AppColor.Label.primary)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(AppColor.Background.secondary)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AppColor.Border.superStrong, lineWidth: 1)
        )
    }
}

// MARK: - Treat Badge (Selected)

struct TreatBadgeSelected: View {
    let treat: Treat

    var body: some View {
        HStack(spacing: 4) {
            Text(treat.emoji)
                .font(.system(size: 20))

            if treat.count > 0 {
                Text("\(treat.count)")
                    .font(AppFont.caption.bold())
                    .foregroundStyle(AppColor.Fill.accent)
            }
        }
        .frame(height: 40)
        .padding(.horizontal, 12)
        .background(AppColor.Background.secondary)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AppColor.Border.superStrong, lineWidth: 1)
        )
    }
}

// MARK: - New Treat Button

struct NewTreatButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))

                Text("Treat")
                    .font(AppFont.caption.bold())
            }
            .foregroundStyle(AppColor.Label.primary)
            .padding(.horizontal, 14)
            .frame(height: 40)
            .background(AppColor.Background.secondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppColor.Border.superStrong, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Interaction Bar") {
    VStack(spacing: 20) {
        InteractionBarPreview()
    }
    .padding()
    .background(AppColor.Background.primary)
}

private struct InteractionBarPreview: View {
    @State private var isBooped = false

    var body: some View {
        InteractionBar(
            isBooped: $isBooped,
            boopCount: 1,
            commentCount: 32,
            treats: [
                Treat(id: "pat", emoji: "🤚", count: 1),
            ]
        )
    }
}

#Preview("Atoms") {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            BoopButton(isBooped: .constant(false), count: 1)
            BoopButton(isBooped: .constant(true), count: 1)
        }

        HStack(spacing: 12) {
            CommentButton(count: 32) {}
        }

        HStack(spacing: 12) {
            TreatBadge(treat: Treat(id: "pat", emoji: "🤚", count: 1))
            TreatBadgeSelected(treat: Treat(id: "pat", emoji: "🤚", count: 1))
            NewTreatButton {}
        }
    }
    .padding()
    .background(AppColor.Background.primary)
}
