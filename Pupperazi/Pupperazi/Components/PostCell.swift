import SwiftUI

/// A styled post card showing a dog photo with tag overlays and a headline.
///
/// Appearance is driven entirely by an `ArticleStyle` + `StylePalette` pair,
/// making it easy to add new visual treatments.
struct PostCell<ImageOverlay: View>: View {
    let image: UIImage?
    let headline: String
    let breed: String
    let location: String
    let author: String
    let style: ArticleStyle
    let palette: StylePalette
    var forceSquare: Bool = true
    var showRoundedCorners: Bool = true
    var imageOverlay: ImageOverlay

    var body: some View {
        VStack(spacing: 0) {
            // Image + tag overlays — fills remaining space above headline
            ZStack(alignment: .top) {
                Group {
                    if let image {
                        GeometryReader { geo in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        }
                    } else {
                        Color.gray.opacity(2)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(AppColor.Border.superStrong, lineWidth: 2)
                }
                .overlay(alignment: .bottomLeading) {
                    imageOverlay
                }
                .padding(8)

                // Tag overlays
                HStack {
                    PostTagChip.location(
                        location,
                        background: palette.chipBackground,
                        foreground: palette.chipForeground
                    )

                    Spacer()

                    PostTagChip.breed(
                        breed,
                        background: palette.chipBackground,
                        foreground: palette.chipForeground
                    )
                }
                .padding(16)
            }

            // Headline band
            if style.headlineBand {
                VStack(alignment: .leading, spacing: 0) {
                    Text(headline.uppercased())
                        .font(style.headlineFont)
                        .foregroundStyle(palette.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if !author.isEmpty {
                        Text("Papped by \(author)")
                            .font(AppFont.caption.bold())
                            .foregroundStyle(palette.headline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 12, bottom: 8, trailing: 12))
                .background(palette.background)
            }
        }
        .if(forceSquare) { view in
            view.aspectRatio(1, contentMode: .fit)
        }
        .clipShape(RoundedRectangle(cornerRadius: showRoundedCorners ? style.cornerRadius : 0))
        .overlay(
            RoundedRectangle(cornerRadius: showRoundedCorners ? style.cornerRadius : 0)
                .stroke(palette.border, lineWidth: showRoundedCorners ? style.borderWidth : 0)
        )
        .background(
            RoundedRectangle(cornerRadius: showRoundedCorners ? style.cornerRadius : 0)
                .fill(palette.background)
        )
    }
}

// MARK: - Convenience init (no image overlay)

extension PostCell where ImageOverlay == EmptyView {
    init(
        image: UIImage?,
        headline: String,
        breed: String,
        location: String,
        author: String = "",
        style: ArticleStyle,
        palette: StylePalette,
        forceSquare: Bool = true,
        showRoundedCorners: Bool = true
    ) {
        self.image = image
        self.headline = headline
        self.breed = breed
        self.location = location
        self.author = author
        self.style = style
        self.palette = palette
        self.forceSquare = forceSquare
        self.showRoundedCorners = showRoundedCorners
        self.imageOverlay = EmptyView()
    }
}

// MARK: - Floating headline variant (no band)

extension PostCell {
    /// When the style has no headline band, the headline floats below the image.
    @ViewBuilder
    func withFloatingHeadline() -> some View {
        if !style.headlineBand && !headline.isEmpty {
            VStack(spacing: 8) {
                self

                Text(headline.uppercased())
                    .font(style.headlineFont)
                    .foregroundStyle(palette.headline)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            self
        }
    }
}

// MARK: - Preview

#Preview("Post Cell — Tabloid Orange") {
    PostCell(
        image: nil,
        headline: "Good boy poses with a devastating smolder",
        breed: "Labrador",
        location: "London, UK",
        style: .tabloid,
        palette: ArticleStyle.tabloid.palettes[0]
    )
    .padding(24)
    .background(AppColor.Background.primary)
}

#Preview("Post Cell — Poster Black") {
    PostCell(
        image: nil,
        headline: "Late night zoomies",
        breed: "Corgi",
        location: "Tokyo, JP",
        style: .poster,
        palette: ArticleStyle.poster.palettes[0]
    )
    .padding(24)
    .background(AppColor.Background.primary)
}

#Preview("Post Cell — Minimal Cream") {
    PostCell(
        image: nil,
        headline: "Sunday snooze",
        breed: "Pug",
        location: "NYC, US",
        style: .minimal,
        palette: ArticleStyle.minimal.palettes[0]
    )
    .withFloatingHeadline()
    .padding(24)
    .background(AppColor.Background.primary)
}
