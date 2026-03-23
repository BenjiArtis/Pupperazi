import SwiftUI

// Set to true to enable the debug long-press gesture on the Profile tab
// that resets onboarding. Set to false for release builds.
private let DEBUG_ONBOARDING = true

// MARK: - Root View

struct AppNavigation: View {
    @AppStorage("showOnboarding") private var showOnboarding = true

    var body: some View {
        if showOnboarding {
            OnboardingView {
                withAnimation {
                    showOnboarding = false
                }
            }
        } else {
            MainTabView()
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @AppStorage("showOnboarding") private var showOnboarding = true
    @State private var selectedTab: Tab = .feed
    @State private var showCreateView = false
    @State private var capturedImage: UIImage?
    @State private var showPhotoConfirmation = false

    enum Tab {
        case feed, camera, profile
    }

    init() {
        UITabBar.appearance().isHidden = true

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .feed:
                    NavigationStack {
                        FeedView()
                            .background(ClearNavigationBackground())
                            .navigationBarHidden(true)
                            .navigationDestination(for: FeedDestination.self) { destination in
                                switch destination {
                                case .search:
                                    SearchView()
                                }
                            }
                    }

                case .camera:
                    CameraView(
                        showCreateView: $showCreateView,
                        capturedImage: $capturedImage,
                        showPhotoConfirmation: $showPhotoConfirmation,
                        isActive: selectedTab == .camera
                    )

                case .profile:
                    NavigationStack {
                        ProfileView()
                            .background(ClearNavigationBackground())
                            .navigationBarHidden(true)
                            .navigationDestination(for: ProfileDestination.self) { destination in
                                switch destination {
                                case .notifications:
                                    NotificationsView()
                                case .settings:
                                    SettingsView()
                                }
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !showPhotoConfirmation {
                TabBar(selectedTab: $selectedTab)
                    .if(DEBUG_ONBOARDING) { view in
                        view.onLongPressGesture(minimumDuration: 2) {
                            showOnboarding = true
                        }
                    }
            }
        }
        .background(
            (selectedTab == .camera ? AppColor.Background.inverse : AppColor.Background.primary)
                .ignoresSafeArea()
        )
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $showCreateView) {
            CreateView(
                isPresented: $showCreateView,
                image: capturedImage
            )
        }
    }
}

// MARK: - Navigation Destinations

enum FeedDestination: Hashable {
    case search
}

enum ProfileDestination: Hashable {
    case notifications
    case settings
}

// MARK: - Transparent Navigation Stack

private struct ClearNavigationBackground: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        ClearBackgroundViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private class ClearBackgroundViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            clearBackgrounds()
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            clearBackgrounds()
        }

        private func clearBackgrounds() {
            var vc: UIViewController? = self
            while let current = vc {
                if current is UINavigationController {
                    current.view.backgroundColor = .clear
                    current.view.subviews.forEach { $0.backgroundColor = .clear }
                    break
                }
                current.view.backgroundColor = .clear
                vc = current.parent
            }
        }
    }
}

// MARK: - Conditional Modifier

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    AppNavigation()
}
