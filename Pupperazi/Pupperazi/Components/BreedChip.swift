import SwiftUI

/// A pill-shaped chip displaying a dog breed with a paw icon.
struct BreedChip: View {
    let breed: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 14, weight: .bold))

            Text(breed.uppercased())
                .font(AppFont.brandTitle)
        }
        .foregroundStyle(AppColor.Label.primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .stroke(AppColor.Border.superStrong, lineWidth: 2)
        )
    }
}

// MARK: - Preview

#Preview("Breed Chip") {
    VStack(spacing: 16) {
        BreedChip(breed: "Labrador")
        BreedChip(breed: "Golden Retriever")
        BreedChip(breed: "Pug")
    }
    .padding()
    .background(AppColor.Background.primary)
}
