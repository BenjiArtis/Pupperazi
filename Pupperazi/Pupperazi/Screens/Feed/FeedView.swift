import SwiftUI

enum FeedTab: Hashable, CaseIterable {
    case frontPage, boopBracket, london, labrador
}

struct FeedView: View {
    @State private var scrolledTab: FeedTab? = .frontPage
    @State private var selectedFeedTab: FeedTab = .frontPage
    @State private var posts: [Post] = Post.samples
    @State private var currentPostIndex: Int = 0
    @State private var previousTabIndex: Int = 0

    // Boop Bracket state
    @State private var bracket: BoopBracket = BoopBracket.sample
    @State private var bracketPageIndex: Int = 0

    private let allTabs = FeedTab.allCases

    private var safePostIndex: Int {
        min(max(currentPostIndex, 0), posts.count - 1)
    }

    private var currentPost: Binding<Post> {
        $posts[safePostIndex]
    }

    /// The bracket matchup for the current page (nil if on the cover).
    private var currentMatchup: BracketMatchup? {
        let matchupIndex = bracketPageIndex - 1
        guard matchupIndex >= 0 && matchupIndex < bracket.matchups.count else { return nil }
        return bracket.matchups[matchupIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar(title: "Pupperazzi") {
                NavigationLink(value: FeedDestination.search) {
                    NavBarAccessoryButton(icon: .search) {}
                        .allowsHitTesting(false)
                }
            }.zIndex(3)
                .background(AppColor.Background.primary)
            TabControl(
                tabs: [
                    ("Front Page", FeedTab.frontPage),
                    ("Boop Bracket", .boopBracket),
                    ("#London", .london),
                    ("#Labrador", .labrador),
                ],
                selectedTab: $selectedFeedTab
            ).background(LinearGradient(colors: [AppColor.Background.primary, AppColor.Background.primary.opacity(0)], startPoint: .top, endPoint: .bottom))
                .zIndex(3)

            // Vertical paging through tabs, horizontal page curl within each
            GeometryReader { geo in
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(allTabs, id: \.self) { tab in
                            Group {
                                if tab == .boopBracket {
                                    bracketContent(height: geo.size.height)
                                } else {
                                    regularFeedContent(height: geo.size.height)
                                }
                            }
                            .frame(height: geo.size.height)
                            .offset(y: tabOffset(for: tab))
                            .overlay(
                                AppColor.Background.primary
                                    .opacity(selectedFeedTab == tab ? 0 : 1)
                                    .allowsHitTesting(false)
                            )
                            .animation(.easeInOut(duration: 0.35), value: selectedFeedTab)
                            .id(tab)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollClipDisabled()
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $scrolledTab)
                .scrollIndicators(.hidden)
                .onChange(of: scrolledTab) { _, newTab in
                    if let newTab {
                        previousTabIndex = allTabs.firstIndex(of: selectedFeedTab) ?? 0
                        selectedFeedTab = newTab
                    }
                }
                .onChange(of: selectedFeedTab) { oldTab, newTab in
                    previousTabIndex = allTabs.firstIndex(of: oldTab) ?? 0
                    withAnimation {
                        scrolledTab = newTab
                    }
                }
            }
            .zIndex(1)

            // Interaction bar — switches based on active tab
            interactionBar
                .padding(.vertical, 8)
                .background(LinearGradient(colors: [AppColor.Background.primary.opacity(0), AppColor.Background.primary], startPoint: .top, endPoint: .bottom))
                .animation(.easeInOut(duration: 0.2), value: currentPostIndex)
                .animation(.easeInOut(duration: 0.2), value: bracketPageIndex)
                .zIndex(2)
        }
        .background(.clear)
    }

    // MARK: - Regular Feed Content

    @ViewBuilder
    private func regularFeedContent(height: CGFloat) -> some View {
        PageCurlView(
            pageCount: posts.count,
            currentPage: $currentPostIndex
        ) { index in
            PostCell(
                image: posts[index].image,
                headline: posts[index].headline,
                breed: posts[index].breed,
                location: posts[index].location,
                style: posts[index].style,
                palette: posts[index].palette,
                forceSquare: false,
                showRoundedCorners: false
            )
            .overlay(Rectangle().strokeBorder(AppColor.Border.superStrong, style: StrokeStyle(lineWidth: 2)))
        }
    }

    // MARK: - Bracket Content

    @ViewBuilder
    private func bracketContent(height: CGFloat) -> some View {
        PageCurlView(
            pageCount: bracket.pageCount,
            currentPage: $bracketPageIndex
        ) { pageIndex in
            bracketPage(for: pageIndex)
                .overlay(Rectangle().strokeBorder(AppColor.Border.superStrong, style: StrokeStyle(lineWidth: 2)))
        }
    }

    @ViewBuilder
    private func bracketPage(for pageIndex: Int) -> some View {
        if pageIndex == 0 {
            BracketCoverPage(
                roundName: bracket.roundName,
                matchupCount: bracket.matchups.count
            )
        } else {
            let matchupIndex = pageIndex - 1
            BracketMatchupView(
                matchup: bracket.matchups[min(matchupIndex, bracket.matchups.count - 1)]
            )
        }
    }

    // MARK: - Interaction Bar

    @ViewBuilder
    private var interactionBar: some View {
        if selectedFeedTab == .boopBracket {
            if bracketPageIndex == 0 {
                // Cover page — "Get Voting!" button
                BracketCoverBar {
                    bracketPageIndex = 1
                }
            } else if let matchup = currentMatchup {
                // Matchup page — vote buttons
                BracketInteractionBar(
                    matchup: matchup,
                    onVoteTop: { voteInBracket(.top) },
                    onVoteBottom: { voteInBracket(.bottom) }
                )
            }
        } else {
            // Standard post interaction bar
            InteractionBar(
                isBooped: currentPost.isBooped,
                boopCount: posts[safePostIndex].boopCount,
                commentCount: posts[safePostIndex].commentCount,
                treats: posts[safePostIndex].treats
            )
        }
    }

    // MARK: - Actions

    private func voteInBracket(_ vote: BracketVote) {
        let matchupIndex = bracketPageIndex - 1
        guard matchupIndex >= 0 && matchupIndex < bracket.matchups.count else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            bracket.matchups[matchupIndex].votedFor = vote
        }
    }

    /// Returns a vertical offset for non-active tabs so they appear to slide off/on.
    private func tabOffset(for tab: FeedTab) -> CGFloat {
        guard selectedFeedTab != tab else { return 0 }
        let tabIndex = allTabs.firstIndex(of: tab) ?? 0
        let currentIndex = allTabs.firstIndex(of: selectedFeedTab) ?? 0
        // Push inactive tabs in the direction they'd be relative to current
        return tabIndex < currentIndex ? -40 : 40
    }
}
