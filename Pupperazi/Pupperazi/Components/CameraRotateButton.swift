import SwiftUI

// MARK: - Camera Rotate Button

struct CameraRotateButton: View {
    let action: () -> Void

    @State private var rotation: Double = 0

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                rotation += 360
            }
            action()
        } label: {
            Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(AppColor.Background.primary)
                .frame(width: 48, height: 48)
                .rotationEffect(.degrees(rotation))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Camera Rotate") {
    CameraRotateButton {}
        .padding()
        .background(AppColor.Background.inverse)
}
