import SwiftUI

// MARK: - Navigation Bar

struct NavigationBar<TrailingContent: View>: View {
    let title: String
    @ViewBuilder var trailing: () -> TrailingContent

    init(
        title: String,
        @ViewBuilder trailing: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.Label.primary)
                    .textCase(.uppercase)

                Spacer()

                HStack(spacing: 16) {
                    trailing()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Overlay Navigation Bar (centered title + leading close)

/// Navigation bar for overlay/modal flows. Leading accessory button (typically close),
/// centered title, and an equal-sized trailing spacer to keep the title centered.
struct OverlayNavigationBar: View {
    let title: String
    var leadingIcon: NavBarAccessoryButton.Icon = .close
    var onLeadingAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Centered title
                Text(title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.Label.primary)
                    .textCase(.uppercase)

                // Leading button pinned to the left
                HStack {
                    NavBarAccessoryButton(icon: leadingIcon, action: onLeadingAction)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Camera Navigation Bar (spacer only)

struct CameraNavigationBar: View {
    var body: some View {
        Color.clear
            .frame(height: 8)
    }
}

// MARK: - Previews

#Preview("Home / Feed") {
    VStack(spacing: 0) {
        NavigationBar(title: "Pupperazzi") {
            NavBarAccessoryButton(icon: .search) {}
        }

        TabControl(
            tabs: [
                ("Front Page", "frontPage"),
                ("Boop Bracket", "boopBracket"),
                ("#London", "london"),
                ("#Labrador", "labrador"),
            ],
            selectedTab: .constant("frontPage")
        )

        Spacer()
    }
    .background(AppColor.Background.primary)
}

#Preview("Overlay / Create") {
    VStack(spacing: 0) {
        OverlayNavigationBar(title: "Dog Breed") {}
        Spacer()
    }
    .background(AppColor.Background.primary)
}

#Preview("Camera") {
    VStack(spacing: 0) {
        CameraNavigationBar()
        Spacer()
    }
    .background(AppColor.Background.primary)
}

#Preview("Profile") {
    VStack(spacing: 0) {
        NavigationBar(title: "benjiartis") {
            NavBarAccessoryButton(icon: .activity, showBadge: true) {}
            NavBarAccessoryButton(icon: .settings) {}
        }
        Spacer()
    }
    .background(AppColor.Background.primary)
}
