import SwiftUI

/// A horizontal row of colour swatches for picking a style palette.
struct PalettePicker: View {
    let palettes: [StylePalette]
    @Binding var selected: StylePalette

    var body: some View {
        HStack(spacing: 12) {
            ForEach(palettes) { palette in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selected = palette
                    }
                } label: {
                    Circle()
                        .fill(palette.background)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(palette.border, lineWidth: 1.5)
                        )
                        .overlay(
                            Circle()
                                .stroke(AppColor.Fill.accent, lineWidth: 2.5)
                                .padding(-3)
                                .opacity(selected.id == palette.id ? 1 : 0)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Preview

#Preview("Palette Picker") {
    PalettePickerPreview()
        .padding()
        .background(AppColor.Background.primary)
}

private struct PalettePickerPreview: View {
    @State private var selected = ArticleStyle.tabloid.palettes[0]

    var body: some View {
        PalettePicker(
            palettes: ArticleStyle.tabloid.palettes,
            selected: $selected
        )
    }
}
