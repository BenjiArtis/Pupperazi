import SwiftUI

/// A styled post card showing a dog photo with tag overlays and a headline.
///
/// Appearance is driven entirely by an `ArticleStyle` + `StylePalette` pair,
/// making it easy to add new visual treatments.
struct PostCell: View {
    let image: UIImage?
    let headline: String
    let breed: String
    let location: String
    let style: ArticleStyle
    let palette: StylePalette
    var forceSquare: Bool = true
    var showRoundedCorners: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            // Image + tag overlays — fills remaining space above headline
            ZStack(alignment: .top) {
                if let image {
                    GeometryReader { geo in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                } else {
                    Color.gray.opacity(0.2)
                }

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
                .padding(10)
            }

            // Headline band
            if style.headlineBand {
                HStack {
                    Text(headline.uppercased())
                        .font(style.headlineFont)
                        .foregroundStyle(palette.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
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
