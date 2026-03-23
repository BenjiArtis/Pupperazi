import SwiftUI

/// A single matchup between two posts in a Boop Bracket round.
struct BracketMatchup: Identifiable {
    let id: String
    let postA: Post
    let postB: Post
    var votedFor: BracketVote?
    /// Pre-baked community vote percentages (purely cosmetic for now).
    var percentA: Int = 50
    var percentB: Int = 50

    var hasVoted: Bool { votedFor != nil }

    var winner: BracketVote? {
        guard hasVoted else { return nil }
        if percentA > percentB { return .top }
        if percentB > percentA { return .bottom }
        return nil
    }
}

enum BracketVote {
    case top, bottom
}

/// A full bracket round — cover info + matchups.
struct BoopBracket: Identifiable {
    let id: String
    let roundName: String
    var matchups: [BracketMatchup]

    /// Total pages: 1 cover + N matchups + 1 results.
    var pageCount: Int { 1 + matchups.count + 1 }

    /// Whether every matchup has been voted on.
    var allVoted: Bool { matchups.allSatisfy(\.hasVoted) }

    /// Index of the results page.
    var resultsPageIndex: Int { 1 + matchups.count }
}

// MARK: - Sample Data

extension BoopBracket {
    static let sample: BoopBracket = {
        let posts = Post.samples
        return BoopBracket(
            id: "bracket-1",
            roundName: "Semi-Finals",
            matchups: [
                BracketMatchup(
                    id: "match-1",
                    postA: posts[0],
                    postB: posts[1],
                    percentA: 62,
                    percentB: 38
                ),
                BracketMatchup(
                    id: "match-2",
                    postA: posts[2],
                    postB: posts[3],
                    percentA: 44,
                    percentB: 56
                ),
            ]
        )
    }()
}
