import SwiftUI

// MARK: - Shutter Button

struct ShutterButton: View {
    let action: () -> Void
    var appeared: Bool = true

    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                // Outer ring
                Circle()
                    .strokeBorder(AppColor.Border.inverse, lineWidth: 3)
                    .frame(width: 100, height: 100)

                // Inner fill
                Circle()
                    .fill(AppColor.Background.primary)
                    .frame(width: 86, height: 86)
                    .scaleEffect(isPressed ? 0.85 : 1.0)
            }
            .scaleEffect(appeared ? 1.0 : 0.3)
            .opacity(appeared ? 1.0 : 0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Previews

#Preview("Shutter Button") {
    ShutterButton {}
        .padding(40)
        .background(AppColor.Background.inverse)
}
