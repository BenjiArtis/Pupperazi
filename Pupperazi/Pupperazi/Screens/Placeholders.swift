import SwiftUI

// MARK: - Search

struct SearchView: View {
    var body: some View {
        ZStack {
            AppColor.Background.primary.ignoresSafeArea()
            Text("SearchView")
                .font(AppFont.title)
                .foregroundStyle(AppColor.Label.primary)
        }
        .navigationTitle("Search")
    }
}

// MARK: - Notifications

struct NotificationsView: View {
    var body: some View {
        ZStack {
            AppColor.Background.primary.ignoresSafeArea()
            Text("NotificationsView")
                .font(AppFont.title)
                .foregroundStyle(AppColor.Label.primary)
        }
        .navigationTitle("Notifications")
    }
}

// MARK: - Settings

struct SettingsView: View {
    @AppStorage("showOnboarding") private var showOnboarding = true

    var body: some View {
        ZStack {
            AppColor.Background.primary.ignoresSafeArea()

            List {
                Section("Debug") {
                    Button("Replay Onboarding") {
                        showOnboarding = true
                    }
                    .foregroundStyle(AppColor.Fill.accent)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
    }
}
