import SwiftUI

// MARK: - Flash Mode

enum FlashMode: CaseIterable {
    case on, auto, off

    var iconName: String {
        switch self {
        case .on: "bolt.fill"
        case .auto: "bolt.badge.automatic.fill"
        case .off: "bolt.slash.fill"
        }
    }
}

// MARK: - Flash Button

struct FlashButton: View {
    @Binding var mode: FlashMode

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                mode = mode.next
            }
        } label: {
            Image(systemName: mode.iconName)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(mode == .off ? AppColor.Label.tertiary : AppColor.Background.primary)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
    }
}

private extension FlashMode {
    var next: FlashMode {
        let all = FlashMode.allCases
        let idx = all.firstIndex(of: self)!
        return all[(idx + 1) % all.count]
    }
}

// MARK: - Previews

#Preview("Flash Button") {
    struct Wrapper: View {
        @State var mode: FlashMode = .on

        var body: some View {
            VStack(spacing: 32) {
                FlashButton(mode: $mode)
                Text("Mode: \(String(describing: mode))")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.Label.tertiary)
            }
            .padding()
            .background(AppColor.Background.inverse)
        }
    }
    return Wrapper()
}

#Preview("Flash States") {
    HStack(spacing: 24) {
        FlashButton(mode: .constant(.on))
        FlashButton(mode: .constant(.auto))
        FlashButton(mode: .constant(.off))
    }
    .padding()
    .background(AppColor.Background.inverse)
}
