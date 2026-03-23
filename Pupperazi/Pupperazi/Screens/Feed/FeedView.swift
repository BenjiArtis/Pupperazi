import SwiftUI

enum FeedTab: Hashable {
    case frontPage, boopBracket, london, labrador
}

struct FeedView: View {
    @State private var selectedFeedTab: FeedTab = .frontPage
    @State private var posts: [Post] = Post.samples
    @State private var currentPostIndex: Int = 0

    private var currentPost: Binding<Post> {
        $posts[currentPostIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar(title: "Pupperazzi") {
                NavigationLink(value: FeedDestination.search) {
                    NavBarAccessoryButton(icon: .search) {}
                        .allowsHitTesting(false)
                }
            }

            TabControl(
                tabs: [
                    ("Front Page", FeedTab.frontPage),
                    ("Boop Bracket", .boopBracket),
                    ("#London", .london),
                    ("#Labrador", .labrador),
                ],
                selectedTab: $selectedFeedTab
            )

            // Page curl post feed
            PageCurlView(
                pageCount: posts.count,
                currentPage: $currentPostIndex
            ) { index in
                PostCell(
                    image: nil,
                    headline: posts[index].headline,
                    breed: posts[index].breed,
                    location: posts[index].location,
                    style: posts[index].style,
                    palette: posts[index].palette,
                    forceSquare: false,
                    showRoundedCorners: false
                ).overlay(Rectangle().strokeBorder(AppColor.Border.superStrong, style: StrokeStyle(lineWidth: 2)))
            }.zIndex(2)

            // Interaction bar for current post
            InteractionBar(
                isBooped: currentPost.isBooped,
                boopCount: posts[currentPostIndex].boopCount,
                commentCount: posts[currentPostIndex].commentCount,
                treats: posts[currentPostIndex].treats
            )
            .padding(.vertical, 8)
            .animation(.easeInOut(duration: 0.2), value: currentPostIndex)
            .zIndex(1)
        }
        .background(.clear)
    }
}
