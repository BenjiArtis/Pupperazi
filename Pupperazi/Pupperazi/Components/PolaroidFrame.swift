import SwiftUI

/// A polaroid-style photo frame with a white border, thicker at the bottom.
struct PolaroidFrame<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(AppColor.Border.superStrong, lineWidth: 2)
            }
            .padding(.top, 12)
            .padding(.horizontal, 12)
            .padding(.bottom, 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.25), radius: 0, y: 8)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.Border.superStrong, lineWidth: 2)
            }
    }
}

// MARK: - Preview

#Preview("Polaroid Frame") {
    ZStack {
        AppColor.Background.inverse.ignoresSafeArea()

        PolaroidFrame {
            Image(systemName: "dog.fill")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 260)
                .foregroundStyle(.gray)
                .background(Color.gray.opacity(0.2))
        }
        .padding(40)
    }
}
