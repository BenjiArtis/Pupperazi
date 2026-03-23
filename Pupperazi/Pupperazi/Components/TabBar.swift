import SwiftUI

// MARK: - Tab Bar

struct TabBar: View {
    @Binding var selectedTab: MainTabView.Tab

    var profileImage: Image?

    private var isCamera: Bool { selectedTab == .camera }

    var body: some View {
        VStack(spacing: 0) {
            if !isCamera {
                Divider()
                    .overlay(AppColor.Border.default)
            }

            HStack(spacing: 0) {
                TabBarOption(
                    tab: .feed,
                    selectedTab: $selectedTab,
                    darkMode: isCamera
                )
                .frame(maxWidth: 100, maxHeight: .infinity)

                TabBarOption(
                    tab: .camera,
                    selectedTab: $selectedTab,
                    darkMode: isCamera
                )
                .frame(maxWidth: 100, maxHeight: .infinity)

                TabBarOption(
                    tab: .profile,
                    selectedTab: $selectedTab,
                    profileImage: profileImage,
                    darkMode: isCamera
                )
                .frame(maxWidth: 100, maxHeight: .infinity)
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
        }.background(.clear)
    }
}

// MARK: - Tab Bar Option

struct TabBarOption: View {
    let tab: MainTabView.Tab
    @Binding var selectedTab: MainTabView.Tab

    var profileImage: Image?
    var darkMode: Bool = false

    private var isSelected: Bool { selectedTab == tab }

    private var selectedColor: Color { darkMode ? AppColor.Label.inverse : AppColor.Label.primary }
    private var unselectedColor: Color { AppColor.Label.tertiary }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = tab
            }
        } label: {
            tabContent
                .scaleEffect(isSelected && tab != .camera ? 1.15 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch tab {
        case .feed:
            Image(systemName: "magazine.fill")
                .font(.system(size: 28))
                .foregroundStyle(isSelected ? selectedColor : unselectedColor)

        case .camera:
            // Normal icon when unselected, fades out when selected (shutter takes over)
            Image(systemName: "camera.fill")
                .font(.system(size: 28))
                .foregroundStyle(unselectedColor)
                .opacity(isSelected ? 0 : 1)
                .scaleEffect(isSelected ? 1.5 : 1.0)

        case .profile:
            profileIcon
        }
    }

    @ViewBuilder
    private var profileIcon: some View {
        let borderColor = isSelected
            ? (darkMode ? AppColor.Border.inverse : AppColor.Border.superStrong)
            : AppColor.Border.default

        if let profileImage {
            profileImage
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: isSelected ? 2.5 : 1.5)
                )
        } else {
            Circle()
                .fill(AppColor.Fill.accentSecondary)
                .frame(width: 36, height: 36)
                .overlay(
                    Text("P")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.Label.primary)
                )
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: isSelected ? 2.5 : 1.5)
                )
        }
    }
}

// MARK: - Previews

#Preview("Tab Bar — Feed Selected") {
    PreviewWrapper(selectedTab: .feed)
}

#Preview("Tab Bar — Camera Selected") {
    PreviewWrapper(selectedTab: .camera)
}

#Preview("Tab Bar — Profile Selected") {
    PreviewWrapper(selectedTab: .profile)
}

#Preview("Tab Bar — Interactive") {
    PreviewWrapper(selectedTab: .feed)
}

private struct PreviewWrapper: View {
    @State var selectedTab: MainTabView.Tab

    var body: some View {
        VStack {
            Spacer()
            TabBar(selectedTab: $selectedTab)
        }
        .background(AppColor.Background.primary)
    }
}
