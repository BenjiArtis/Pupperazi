import SwiftUI

// MARK: - Tab Control

struct TabControl<Tab: Hashable>: View {
    let tabs: [(label: String, value: Tab)]
    @Binding var selectedTab: Tab

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(tabs, id: \.value) { tab in
                    TabControlItem(
                        label: tab.label,
                        isSelected: selectedTab == tab.value
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab.value
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Tab Control Item

private struct TabControlItem: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(label)
                    .font(AppFont.title.bold())
                    .foregroundStyle(isSelected ? AppColor.Label.primary : AppColor.Label.tertiary)

                RoundedRectangle(cornerRadius: 1.5)
                    .fill(AppColor.Fill.accent)
                    .frame(height: 3)
                    .opacity(isSelected ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

private enum PreviewFeedTab: Hashable {
    case frontPage, boopBracket, london, labrador
}

#Preview("Tab Control") {
    struct Wrapper: View {
        @State var selected: PreviewFeedTab = .frontPage

        var body: some View {
            TabControl(
                tabs: [
                    ("Front Page", PreviewFeedTab.frontPage),
                    ("Boop Bracket", .boopBracket),
                    ("#London", .london),
                    ("#Labrador", .labrador),
                ],
                selectedTab: $selected
            )
            .padding(.vertical, 16)
            .background(AppColor.Background.primary)
        }
    }
    return Wrapper()
}
