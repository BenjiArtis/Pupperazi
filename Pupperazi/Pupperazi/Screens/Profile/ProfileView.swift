import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 0) {
            NavigationBar(title: "benjiartis") {
                NavigationLink(value: ProfileDestination.notifications) {
                    NavBarAccessoryButton(icon: .activity, showBadge: true) {}
                        .allowsHitTesting(false)
                }
                NavigationLink(value: ProfileDestination.settings) {
                    NavBarAccessoryButton(icon: .settings) {}
                        .allowsHitTesting(false)
                }
            }

            Spacer()

            Text("Profile")
                .font(AppFont.body)
                .foregroundStyle(AppColor.Label.tertiary)

            Spacer()
        }
    }
}
