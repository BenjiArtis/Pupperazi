import SwiftUI

// MARK: - Nav Bar Accessory Button

struct NavBarAccessoryButton: View {
    let icon: Icon
    var showBadge: Bool = false
    let action: () -> Void

    enum Icon {
        case search
        case activity
        case settings
        case close

        var systemName: String {
            switch self {
            case .search: "magnifyingglass"
            case .activity: "bell.fill"
            case .settings: "gearshape.fill"
            case .close: "xmark"
            }
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon.systemName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppColor.Label.primary)

                if showBadge {
                    Circle()
                        .fill(AppColor.Fill.accent)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(AppColor.Background.primary, lineWidth: 1.5)
                        )
                        .offset(x: 3, y: -2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Search") {
    NavBarAccessoryButton(icon: .search) {}
        .padding()
        .background(AppColor.Background.primary)
}

#Preview("Activity") {
    HStack(spacing: 32) {
        NavBarAccessoryButton(icon: .activity) {}
        NavBarAccessoryButton(icon: .activity, showBadge: true) {}
    }
    .padding()
    .background(AppColor.Background.primary)
}

#Preview("Settings") {
    NavBarAccessoryButton(icon: .settings) {}
        .padding()
        .background(AppColor.Background.primary)
}
