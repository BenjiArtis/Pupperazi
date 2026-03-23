import SwiftUI

/// A single post in the feed.
struct Post: Identifiable, Hashable {
    let id: String
    let imageName: String
    let headline: String
    let breed: String
    let location: String
    let author: String
    let style: ArticleStyle
    let palette: StylePalette
    var boopCount: Int
    var isBooped: Bool
    var commentCount: Int
    var treats: [Treat]

    /// Loads the image from the bundle's doggo-JPEGS resource folder.
    var image: UIImage? {
        guard let path = Bundle.main.path(forResource: imageName, ofType: "jpeg") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }

    static func == (lhs: Post, rhs: Post) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Sample Data

extension Post {
    static let samples: [Post] = [
        Post(
            id: "1",
            imageName: "01G6DD7K1HN9QBR2Z426ZQ9H7H-hi-res-branded-",
            headline: "Good boy poses with a devastating smolder",
            breed: "Labrador",
            location: "London, UK",
            author: "@benjiartis",
            style: .tabloid,
            palette: ArticleStyle.tabloid.palettes[0],
            boopCount: 42,
            isBooped: false,
            commentCount: 32,
            treats: [Treat(id: "pat", emoji: "🤚", count: 5)]
        ),
        Post(
            id: "2",
            imageName: "01G6J54P47H15D8HTFB75PP6ER-hi-res-branded-",
            headline: "Late night zoomies in the park",
            breed: "Corgi",
            location: "Tokyo, JP",
            author: "@dogspotter",
            style: .poster,
            palette: ArticleStyle.poster.palettes[0],
            boopCount: 128,
            isBooped: true,
            commentCount: 64,
            treats: [
                Treat(id: "bone", emoji: "🦴", count: 12),
                Treat(id: "love", emoji: "❤️", count: 8),
            ]
        ),
        Post(
            id: "3",
            imageName: "01G74NFNG10SBQ0427KCTNW7M6-hi-res-branded-",
            headline: "Sunday snooze on the sofa",
            breed: "Pug",
            location: "NYC, US",
            author: "@puglife",
            style: .tabloid,
            palette: ArticleStyle.tabloid.palettes[2],
            boopCount: 7,
            isBooped: false,
            commentCount: 3,
            treats: []
        ),
        Post(
            id: "4",
            imageName: "01G84BEMEVRBCSN7W569RW1PCS-hi-res-branded-",
            headline: "First snow day and absolutely losing it",
            breed: "Husky",
            location: "Oslo, NO",
            author: "@snowpaws",
            style: .tabloid,
            palette: ArticleStyle.tabloid.palettes[3],
            boopCount: 256,
            isBooped: false,
            commentCount: 89,
            treats: [
                Treat(id: "pat", emoji: "🤚", count: 22),
                Treat(id: "ball", emoji: "🎾", count: 4),
            ]
        ),
    ]
}
