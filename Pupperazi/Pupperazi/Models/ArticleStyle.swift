import SwiftUI

/// A colour palette that can be applied to an article style.
struct StylePalette: Identifiable, Hashable {
    let id: String
    let name: String
    let background: Color
    let headline: Color
    let chipBackground: Color
    let chipForeground: Color
    let border: Color
}

/// Defines the visual treatment of a post cell — colours, typography weight, and layout details.
struct ArticleStyle: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let palettes: [StylePalette]
    /// Font used for the headline overlay on the post cell.
    let headlineFont: Font
    /// Whether the headline sits inside a solid background band at the bottom.
    let headlineBand: Bool
    /// Corner radius of the post cell.
    let cornerRadius: CGFloat
    /// Border width around the post cell.
    let borderWidth: CGFloat

    static func == (lhs: ArticleStyle, rhs: ArticleStyle) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Built-in Styles

extension ArticleStyle {

    /// Classic tabloid / magazine cover style — bold colours, heavy border, headline band.
    static let tabloid = ArticleStyle(
        id: "tabloid",
        name: "Tabloid",
        description: "Bold magazine cover vibes",
        palettes: [
            StylePalette(
                id: "tabloid-orange",
                name: "Orange",
                background: PrimativeColor.orange,
                headline: PrimativeColor.black,
                chipBackground: PrimativeColor.cream,
                chipForeground: PrimativeColor.black,
                border: PrimativeColor.black,

            ),
            StylePalette(
                id: "tabloid-pink",
                name: "Pink",
                background: PrimativeColor.pink,
                headline: PrimativeColor.cream,
                chipBackground: PrimativeColor.black,
                chipForeground: PrimativeColor.cream,
                border: PrimativeColor.black
            ),
            StylePalette(
                id: "tabloid-blue",
                name: "Blue",
                background: PrimativeColor.blue,
                headline: PrimativeColor.cream,
                chipBackground: PrimativeColor.cream,
                chipForeground: PrimativeColor.black,
                border: PrimativeColor.black
            ),
            StylePalette(
                id: "tabloid-yellow",
                name: "Yellow",
                background: PrimativeColor.yellow,
                headline: PrimativeColor.black,
                chipBackground: PrimativeColor.black,
                chipForeground: PrimativeColor.yellow,
                border: PrimativeColor.black
            ),
        ],
        headlineFont: AppFont.headline,
        headlineBand: true,
        cornerRadius: 12,
        borderWidth: 3
    )

    /// Minimal / clean style — no border, subtle background, floating headline.
    static let minimal = ArticleStyle(
        id: "minimal",
        name: "Minimal",
        description: "Clean and simple",
        palettes: [
            StylePalette(
                id: "minimal-cream",
                name: "Cream",
                background: PrimativeColor.cream,
                headline: PrimativeColor.black,
                chipBackground: PrimativeColor.white,
                chipForeground: PrimativeColor.black,
                border: PrimativeColor.mediumGrey
            ),
            StylePalette(
                id: "minimal-black",
                name: "Black",
                background: PrimativeColor.black,
                headline: PrimativeColor.cream,
                chipBackground: PrimativeColor.darkGrey,
                chipForeground: PrimativeColor.cream,
                border: PrimativeColor.darkGrey
            ),
        ],
        headlineFont: AppFont.subhead,
        headlineBand: false,
        cornerRadius: 16,
        borderWidth: 1
    )

    /// Bold / graphic poster style — heavy type, strong contrast.
    static let poster = ArticleStyle(
        id: "poster",
        name: "Poster",
        description: "Eye-catching graphic style",
        palettes: [
            StylePalette(
                id: "poster-black",
                name: "Black",
                background: PrimativeColor.black,
                headline: PrimativeColor.orange,
                chipBackground: PrimativeColor.orange,
                chipForeground: PrimativeColor.black,
                border: PrimativeColor.orange
            ),
            StylePalette(
                id: "poster-cream",
                name: "Cream",
                background: PrimativeColor.cream,
                headline: PrimativeColor.orange,
                chipBackground: PrimativeColor.orange,
                chipForeground: PrimativeColor.cream,
                border: PrimativeColor.orange
            ),
        ],
        headlineFont: AppFont.hero,
        headlineBand: true,
        cornerRadius: 8,
        borderWidth: 4
    )

    /// All available styles.
    static let all: [ArticleStyle] = [.tabloid, .minimal, .poster]
}
