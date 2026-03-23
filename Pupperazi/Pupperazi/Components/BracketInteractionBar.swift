import SwiftUI
import Combine

/// Interaction bar variant for bracket matchup pages — "Vote TOP" / "Vote BOTTOM" buttons.
///
/// After voting, shows the result with the winning vote highlighted in orange.
struct BracketInteractionBar: View {
    let matchup: BracketMatchup
    var onVoteTop: () -> Void = {}
    var onVoteBottom: () -> Void = {}

    var body: some View {
        HStack(spacing: 8) {
            if matchup.hasVoted {
                // Voted state — show results, highlight the one the user picked
                VoteResultPill(
                    letter: "A",
                    percent: matchup.percentA,
                    isVotedFor: matchup.votedFor == .top
                )

                VoteResultPill(
                    letter: "B",
                    percent: matchup.percentB,
                    isVotedFor: matchup.votedFor == .bottom
                )
            } else {
                // Pre-vote — two vote buttons
                VoteButton(letter: "A") {
                    onVoteTop()
                }

                VoteButton(letter: "B") {
                    onVoteBottom()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: matchup.hasVoted)
    }
}

// MARK: - Cover CTA Bar

/// The interaction bar shown on the bracket cover page — single "Get Voting!" button.
struct BracketCoverBar: View {
    var onTap: () -> Void = {}

    var body: some View {
        HStack {
            Button(action: onTap) {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 14, weight: .bold))

                    Text("Get voting!")
                        .font(AppFont.title.bold())
                }
                .foregroundStyle(AppColor.Label.inverse)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(AppColor.Fill.accent)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

// MARK: - Vote Button

private struct VoteButton: View {
    let letter: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(letter)
                    .font(AppFont.headline)
                    .offset(y: 2)
                Text("Vote")
                    .font(AppFont.title.bold())
            }
            .foregroundStyle(AppColor.Label.primary)
            .frame(maxWidth: .infinity)
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

// MARK: - Vote Result Pill

private struct VoteResultPill: View {
    let letter: String
    let percent: Int
    let isVotedFor: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Empty background
                Capsule()
                    .fill(AppColor.Background.secondary)

                // Percentage fill — anchored to leading edge
                RoundedRectangle(cornerRadius: 4)
                    .fill(isVotedFor ? AppColor.Fill.accent.opacity(0.2) : AppColor.Background.primary)
                    .frame(width: geo.size.width * CGFloat(percent) / 100)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipShape(Capsule())

                // Label
                HStack(spacing: 8) {
                    Text(letter)
                        .font(AppFont.headline)
                        .offset(y: 2)

                    Text("\(percent)%")
                        .font(AppFont.title.bold())
                }
                .foregroundStyle(isVotedFor ? AppColor.Label.highlight : AppColor.Label.primary)

                // Border
                Capsule()
                    .strokeBorder(isVotedFor ? AppColor.Fill.accent : AppColor.Border.superStrong, lineWidth: 2)
            }
        }
        .frame(height: 40)
    }
}

// MARK: - Next Round Countdown Bar

/// Disabled interaction bar shown on the results page with a live countdown.
struct BracketNextRoundBar: View {
    @State private var now = Date()

    /// The target date for the next round (hardcoded for demo).
    private var targetDate: Date {
        Calendar.current.date(byAdding: .hour, value: 2, to: .now.addingTimeInterval(-14 * 60 - 37))!
    }

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var remaining: (hours: Int, minutes: Int, seconds: Int) {
        let delta = max(targetDate.timeIntervalSince(now), 0)
        let h = Int(delta) / 3600
        let m = (Int(delta) % 3600) / 60
        let s = Int(delta) % 60
        return (h, m, s)
    }

    private var countdownString: String {
        let r = remaining
        return String(format: "%02d:%02d:%02d", r.hours, r.minutes, r.seconds)
    }

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.system(size: 14, weight: .bold))

                Text("Next round in \(countdownString)")
                    .font(AppFont.title.bold())
                    .monospacedDigit()
            }
            .foregroundStyle(AppColor.Label.tertiary)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(AppColor.Background.secondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppColor.Border.default, lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .onReceive(timer) { tick in
            now = tick
        }
    }
}

// MARK: - Previews

#Preview("Bracket Interaction — Pre-Vote") {
    VStack(spacing: 20) {
        BracketInteractionBar(
            matchup: BoopBracket.sample.matchups[0]
        )

        BracketCoverBar()
    }
    .padding()
    .background(AppColor.Background.primary)
}

#Preview("Bracket Interaction — Voted") {
    BracketInteractionBar(
        matchup: {
            var m = BoopBracket.sample.matchups[0]
            m.votedFor = .top
            return m
        }()
    )
    .padding()
    .background(AppColor.Background.primary)
}
