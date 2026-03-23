import SwiftUI

/// A scrollable bracket tree showing all matchups, vote results, and connector
/// lines leading to the next round (off-screen).
///
/// Styled to match the dark `BracketCoverPage` aesthetic.
struct BracketResultsPage: View {
    let bracket: BoopBracket

    // Layout constants (must stay in sync between rows and Canvas)
    private let rowHeight: CGFloat = 76
    private let rowGap: CGFloat = 2       // gap between A and B within a pair
    private let pairSpacing: CGFloat = 28  // gap between pairs
    private let connectorWidth: CGFloat = 56

    private var pairHeight: CGFloat { rowHeight * 2 + rowGap }

    var body: some View {
        ZStack {
            AppColor.Background.inverse.ignoresSafeArea()

            VStack(spacing: 0) {
                // Round title
                VStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppColor.Fill.accent)
                        .padding(.bottom, 8)

                    Text("BOOP BRACKET")
                        .font(AppFont.hero)
                        .foregroundStyle(AppColor.Label.inverse)

                    Text(bracket.roundName.uppercased())
                        .font(AppFont.caption.bold())
                        .foregroundStyle(AppColor.Fill.accent)
                }
                .padding(.top, 32)
                .padding(.bottom, 28)

                // Matchup pairs + connector lines overlay
                ZStack(alignment: .topLeading) {
                    // Connector lines drawn on a Canvas behind/beside the rows
                    connectorLines
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Matchup rows
                    VStack(spacing: pairSpacing) {
                        ForEach(bracket.matchups) { matchup in
                            matchupPair(matchup)
                        }
                    }
                    .padding(.trailing, connectorWidth)
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Matchup Pair

    private func matchupPair(_ matchup: BracketMatchup) -> some View {
        VStack(spacing: rowGap) {
            bracketRow(
                post: matchup.postA,
                percent: matchup.percentA,
                isVotedFor: matchup.votedFor == .top,
                hasVoted: matchup.hasVoted
            )

            bracketRow(
                post: matchup.postB,
                percent: matchup.percentB,
                isVotedFor: matchup.votedFor == .bottom,
                hasVoted: matchup.hasVoted
            )
        }
    }

    // MARK: - Bracket Row

    private func bracketRow(post: Post, percent: Int, isVotedFor: Bool, hasVoted: Bool) -> some View {
        HStack(spacing: 10) {
            // Thumbnail
            Group {
                if let image = post.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        isVotedFor ? AppColor.Fill.accent : AppColor.Border.inverse.opacity(0.3),
                        lineWidth: isVotedFor ? 2 : 1
                    )
            )

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(post.headline.uppercased())
                    .font(AppFont.brandTitle.bold())
                    .foregroundStyle(isVotedFor ? AppColor.Label.inverse : AppColor.Label.inverse.opacity(0.5))
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Label(post.location, systemImage: "mappin.and.ellipse")
                    Label(post.breed, systemImage: "pawprint.fill")
                }
                .font(AppFont.label)
                .foregroundStyle(AppColor.Label.inverse.opacity(0.3))
                .lineLimit(1)
            }

            Spacer(minLength: 0)

            // Vote indicator / percentage
            if hasVoted {
                HStack(spacing: 4) {
                    if isVotedFor {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                    }
                    Text("\(percent)%")
                        .font(AppFont.caption.bold())
                }
                .foregroundStyle(isVotedFor ? AppColor.Fill.accent : AppColor.Label.inverse.opacity(0.3))
            }
        }
        .padding(10)
        .frame(height: rowHeight)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isVotedFor ? AppColor.Fill.accent.opacity(0.12) : Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isVotedFor ? AppColor.Fill.accent.opacity(0.5) : Color.white.opacity(0.12),
                    lineWidth: isVotedFor ? 2 : 1
                )
        )
    }

    // MARK: - Connector Lines

    /// Draws bracket connector lines from the vertical centre of each pair,
    /// converging to a single point that leads off to the next round.
    private var connectorLines: some View {
        Canvas { context, size in
            let matchupCount = bracket.matchups.count
            guard matchupCount > 0 else { return }

            let lineColor = Color.white.opacity(0.15)
            let accentColor = AppColor.Fill.accent

            // The rows area starts at x=0 and the connector column is on the right
            let rowsWidth = size.width - connectorWidth
            let startX = rowsWidth + 4 // small gap from row edge
            let midX = rowsWidth + connectorWidth * 0.55
            let endX = size.width

            // Calculate the vertical centre of all pairs combined
            let totalPairsHeight = CGFloat(matchupCount) * pairHeight + CGFloat(matchupCount - 1) * pairSpacing
            let globalCentreY = totalPairsHeight / 2

            for i in 0..<matchupCount {
                // Vertical centre of this pair
                let pairTop = CGFloat(i) * (pairHeight + pairSpacing)
                let pairCentreY = pairTop + pairHeight / 2

                let hasVoted = bracket.matchups[i].hasVoted
                let color = hasVoted ? accentColor : lineColor

                // Line: pair centre → right horizontally → vertical to global centre → right off screen
                var path = Path()
                path.move(to: CGPoint(x: startX, y: pairCentreY))
                path.addLine(to: CGPoint(x: midX, y: pairCentreY))
                path.addLine(to: CGPoint(x: midX, y: globalCentreY))
                path.addLine(to: CGPoint(x: endX, y: globalCentreY))

                context.stroke(
                    path,
                    with: .color(color),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )

                // Small dot where the line leaves the pair
                if hasVoted {
                    let dot = Path(ellipseIn: CGRect(
                        x: startX - 3, y: pairCentreY - 3,
                        width: 6, height: 6
                    ))
                    context.fill(dot, with: .color(accentColor))
                }
            }

            // Dot at the convergence point
            let anyVoted = bracket.matchups.contains(where: \.hasVoted)
            if anyVoted {
                let dot = Path(ellipseIn: CGRect(
                    x: endX - 5, y: globalCentreY - 5,
                    width: 10, height: 10
                ))
                context.fill(dot, with: .color(accentColor.opacity(0.5)))
            }
        }
    }
}

// MARK: - Preview

#Preview("Bracket Results — Voted") {
    BracketResultsPage(
        bracket: {
            var b = BoopBracket.sample
            b.matchups[0].votedFor = .top
            b.matchups[1].votedFor = .bottom
            return b
        }()
    )
}

#Preview("Bracket Results — Partial") {
    BracketResultsPage(
        bracket: {
            var b = BoopBracket.sample
            b.matchups[0].votedFor = .top
            return b
        }()
    )
}
