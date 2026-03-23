import SwiftUI

/// Two PostCells stacked vertically — a single bracket matchup page.
/// Each post has an A/B letter badge overlaid on the image, and after voting
/// the winner is revealed with a checkmark badge.
struct BracketMatchupView: View {
    let matchup: BracketMatchup

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Post A (top)
                bracketPost(
                    matchup.postA,
                    letter: "A",
                    vote: .top,
                    height: geo.size.height / 2
                )

                // Post B (bottom)
                bracketPost(
                    matchup.postB,
                    letter: "B",
                    vote: .bottom,
                    height: geo.size.height / 2
                )
            }
        }
    }

    // MARK: - Bracket Post

    @ViewBuilder
    private func bracketPost(_ post: Post, letter: String, vote: BracketVote, height: CGFloat) -> some View {
        let isVotedFor = matchup.votedFor == vote
        let isNotVotedFor = matchup.hasVoted && !isVotedFor

        PostCell(
            image: post.image,
            headline: post.headline,
            breed: post.breed,
            location: post.location,
            style: post.style,
            palette: post.palette,
            forceSquare: false,
            showRoundedCorners: false,
            imageOverlay: letterBadge(letter: letter, isVotedFor: isVotedFor)
                .padding(8)
        )
        .overlay {
            // Dim the post the user didn't vote for
            if isNotVotedFor {
                Color.black.opacity(0.35)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: height)
        .overlay(
            Rectangle()
                .strokeBorder(AppColor.Border.superStrong, style: StrokeStyle(lineWidth: 2))
        )
    }

    // MARK: - Letter Badge

    private func letterBadge(letter: String, isVotedFor: Bool) -> some View {
        // Always show the letter; add a checkmark overlay when voted
        ZStack {
            Circle()
                .fill(AppColor.Background.secondary)
                .frame(width: 44, height: 44)
            Text(letter)
                .font(AppFont.hero)
                .foregroundStyle(AppColor.Label.tertiary.opacity(0.3))
                .offset(y: 4)
        }
        .overlay {
            Circle()
                .stroke(AppColor.Border.superStrong, lineWidth: 2)
        }
        .overlay(alignment: .center) {
            if isVotedFor {
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(AppColor.Fill.accent)
                    .offset(x: 4, y: -4)
            }
        }
    }

    // MARK: - Result Label

    private func resultLabel(percent: Int, isWinner: Bool) -> some View {
        Text("\(percent)%")
            .font(AppFont.hero)
            .foregroundStyle(isWinner ? AppColor.Fill.accent : .white.opacity(0.6))
    }
}

// MARK: - Preview

#Preview("Bracket Matchup") {
    BracketMatchupView(
        matchup: BoopBracket.sample.matchups[0]
    )
    .ignoresSafeArea()
}

#Preview("Bracket Matchup — Voted") {
    BracketMatchupView(
        matchup: {
            var m = BoopBracket.sample.matchups[0]
            m.votedFor = .bottom
            return m
        }()
    )
    .ignoresSafeArea()
}
