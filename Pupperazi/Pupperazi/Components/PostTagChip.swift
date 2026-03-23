import SwiftUI

/// A small pill chip for overlaying on post images — location or breed tag.
struct PostTagChip: View {
    let label: String
    let icon: String
    var chipBackground: Color = PrimativeColor.cream
    var chipForeground: Color = PrimativeColor.black

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))

            Text(label.uppercased())
                .font(AppFont.label.bold())
        }
        .foregroundStyle(chipForeground)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(chipBackground)
        )
        .overlay {
            Capsule()
                .stroke(AppColor.Border.superStrong, lineWidth: 2)
        }
    }
}

// MARK: - Convenience initialisers

extension PostTagChip {
    /// Location tag with map pin icon.
    static func location(_ name: String, background: Color = PrimativeColor.cream, foreground: Color = PrimativeColor.black) -> PostTagChip {
        PostTagChip(label: name, icon: "mappin.and.ellipse", chipBackground: background, chipForeground: foreground)
    }

    /// Breed tag with pawprint icon.
    static func breed(_ name: String, background: Color = PrimativeColor.cream, foreground: Color = PrimativeColor.black) -> PostTagChip {
        PostTagChip(label: name, icon: "pawprint.fill", chipBackground: background, chipForeground: foreground)
    }
}

// MARK: - Preview

#Preview("Post Tag Chips") {
    VStack(spacing: 12) {
        HStack {
            PostTagChip.location("London, UK")
            PostTagChip.breed("Labrador")
        }

        HStack {
            PostTagChip.location("London, UK", background: PrimativeColor.black, foreground: PrimativeColor.cream)
            PostTagChip.breed("Labrador", background: PrimativeColor.black, foreground: PrimativeColor.cream)
        }
    }
    .padding()
    .background(AppColor.Background.primary)
}
