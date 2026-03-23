import SwiftUI

/// The splash / cover page for a Boop Bracket round.
///
/// Shows the round title, a countdown timer, and a "Get Voting!" CTA.
struct BracketCoverPage: View {
    let roundName: String
    let matchupCount: Int

    var body: some View {
        ZStack {
            AppColor.Background.inverse

            VStack(spacing: 0) {
                Spacer()

                // Trophy icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(AppColor.Fill.accent)
                    .padding(.bottom, 20)

                // Title
                Text("BOOP BRACKET")
                    .font(AppFont.hero)
                    .foregroundStyle(AppColor.Label.inverse)
                    .multilineTextAlignment(.center)

                Text(roundName.uppercased())
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.Fill.accent)
                    .padding(.top, 4)

                // Countdown
                HStack(spacing: 16) {
                    CountdownUnit(value: "02", label: "HRS")
                    CountdownUnit(value: "14", label: "MIN")
                    CountdownUnit(value: "37", label: "SEC")
                }
                .padding(.top, 32)


                Spacer()

                // Swipe hint
                VStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColor.Label.inverse.opacity(0.4))
                    // Match count
                    Text("\(matchupCount) VOTES PENDING")
                        .font(AppFont.caption.bold())
                        .foregroundStyle(AppColor.Label.inverse.opacity(0.5))
                }
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Countdown Unit

private struct CountdownUnit: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFont.hero)
                .foregroundStyle(AppColor.Label.inverse)
                .monospacedDigit()

            Text(label)
                .font(AppFont.label.bold())
                .foregroundStyle(AppColor.Label.inverse.opacity(0.5))
        }
        .frame(width: 64)
    }
}

// MARK: - Preview

#Preview("Bracket Cover") {
    BracketCoverPage(roundName: "Semi-Finals", matchupCount: 2)
}
