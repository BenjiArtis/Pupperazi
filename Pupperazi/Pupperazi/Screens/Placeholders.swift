import SwiftUI

// MARK: - Onboarding

struct OnboardingView: View {
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            AppColor.Background.primary.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Onboarding")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.Label.primary)
                Button("Get Started") {
                    onComplete()
                }
                .font(AppFont.title)
                .foregroundStyle(AppColor.Fill.accent)
            }
        }
    }
}

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
    var body: some View {
        ZStack {
            AppColor.Background.primary.ignoresSafeArea()
            Text("SettingsView")
                .font(AppFont.title)
                .foregroundStyle(AppColor.Label.primary)
        }
        .navigationTitle("Settings")
    }
}
