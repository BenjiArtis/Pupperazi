import SwiftUI

struct CreateView: View {
    @Binding var isPresented: Bool
    var image: UIImage?
    @State private var currentStep = 1
    @State private var selectedBreed = "Labrador"
    @State private var selectedStyle = ArticleStyle.tabloid
    @State private var selectedPalette = ArticleStyle.tabloid.palettes[0]
    @State private var headline = "Add your headline here!"

    private let totalSteps = 4

    private var stepTitle: String {
        switch currentStep {
        case 1: "Dog Breed"
        case 2: "Article Style"
        case 3: "Headline"
        case 4: "Post Pap"
        default: ""
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            OverlayNavigationBar(title: stepTitle) {
                isPresented = false
            }

            // Step content
            Group {
                switch currentStep {
                case 1:
                    BreedRevealStep(
                        image: image,
                        selectedBreed: $selectedBreed
                    )
                case 2:
                    ArticleStyleStep(
                        image: image,
                        breed: selectedBreed,
                        headline: headline,
                        selectedStyle: $selectedStyle,
                        selectedPalette: $selectedPalette
                    )
                case 3:
                    HeadlineStep(
                        image: image,
                        breed: selectedBreed,
                        style: selectedStyle,
                        palette: selectedPalette,
                        headline: $headline
                    )
                case 4:
                    PostConfirmStep(
                        image: image,
                        breed: selectedBreed,
                        headline: headline,
                        style: selectedStyle,
                        palette: selectedPalette
                    )
                default:
                    EmptyView()
                }
            }
            .frame(maxHeight: .infinity)

            SteppedNavigation(
                totalSteps: totalSteps,
                currentStep: $currentStep,
                doneLabel: "Post it!",
                onDone: {
                    isPresented = false
                }
            )
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .ignoresSafeArea(.keyboard)
        .background(AppColor.Background.primary.ignoresSafeArea())
    }
}

// MARK: - Step 1: Breed Reveal

struct BreedRevealStep: View {
    let image: UIImage?
    @Binding var selectedBreed: String

    private let breeds = [
        "Labrador", "Golden Retriever", "Pug", "Bulldog", "Beagle",
        "Poodle", "Rottweiler", "Husky", "Corgi", "Dalmatian",
        "German Shepherd", "Border Collie", "Shiba Inu", "Dachshund",
        "French Bulldog", "Chihuahua", "Great Dane", "Boxer",
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Polaroid preview — fills available height
            if let image {
                PolaroidFrame {
                    GeometryReader { geo in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.width)
                            .clipped()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }

            Spacer()

            // Breed info
            VStack(spacing: 12) {
                Text("YOU PAPPED A:")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.Label.primary)

                BreedChip(breed: selectedBreed)

                Menu {
                    ForEach(breeds, id: \.self) { breed in
                        Button(breed) {
                            withAnimation {
                                selectedBreed = breed
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Change breed")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.Label.secondary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AppColor.Label.secondary)
                    }
                }
            }
            .padding(.bottom, 8)

            Spacer()
        }
    }
}

// MARK: - Step 2: Article Style

struct ArticleStyleStep: View {
    let image: UIImage?
    let breed: String
    let headline: String
    @Binding var selectedStyle: ArticleStyle
    @Binding var selectedPalette: StylePalette

    private let styles = ArticleStyle.all

    @GestureState private var dragOffset: CGFloat = 0
    @State private var currentIndex: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Style carousel — manual swipe
            GeometryReader { geo in
                let cardWidth = geo.size.width - 48 // 24px padding each side
                HStack(spacing: 0) {
                    ForEach(Array(styles.enumerated()), id: \.element.id) { index, style in
                        PostCell(
                            image: image,
                            headline: headline,
                            breed: breed,
                            location: "London, UK",
                            style: style,
                            palette: style == selectedStyle ? selectedPalette : style.palettes[0]
                        )
                        .padding(.horizontal, 24)
                        .frame(width: geo.size.width)
                        .tag(style)
                    }
                }
                .offset(x: -CGFloat(currentIndex) * geo.size.width + dragOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = cardWidth * 0.25
                            var newIndex = currentIndex
                            if value.translation.width < -threshold {
                                newIndex = min(currentIndex + 1, styles.count - 1)
                            } else if value.translation.width > threshold {
                                newIndex = max(currentIndex - 1, 0)
                            }
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                currentIndex = newIndex
                                selectedStyle = styles[newIndex]
                            }
                        }
                )
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: dragOffset)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(.top, 8)
            .onChange(of: selectedStyle) { _, newStyle in
                withAnimation {
                    selectedPalette = newStyle.palettes[0]
                }
            }

            // Page dots
            HStack(spacing: 6) {
                ForEach(Array(styles.enumerated()), id: \.element.id) { index, _ in
                    Circle()
                        .fill(index == currentIndex ? AppColor.Fill.accent : AppColor.Border.default)
                        .frame(width: 7, height: 7)
                }
            }
            .padding(.top, 8)

            Spacer()

            // Style info + palette picker
            VStack(spacing: 12) {
                Text(selectedStyle.name.uppercased())
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.Label.primary)

                Text(selectedStyle.description)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.Label.secondary)

                if selectedStyle.palettes.count > 1 {
                    PalettePicker(
                        palettes: selectedStyle.palettes,
                        selected: $selectedPalette
                    )
                    .padding(.top, 4)
                }
            }
            .padding(.bottom, 8)

            Spacer()
        }
    }
}

// MARK: - Step 3: Headline

struct HeadlineStep: View {
    let image: UIImage?
    let breed: String
    let style: ArticleStyle
    let palette: StylePalette
    @Binding var headline: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Post preview — updates live
            PostCell(
                image: image,
                headline: headline.isEmpty ? "Add a headline" : headline,
                breed: breed,
                location: "London, UK",
                style: style,
                palette: palette
            )
            .padding(.horizontal, 24)
            .padding(.top, 8)

            Spacer()

            // Headline text field — fades out while typing, visible when dismissed
            TextField("Add a headline", text: $headline)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.Label.primary)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .focused($isFocused)
                .opacity(isFocused ? 0 : 1)
                .onSubmit {
                    isFocused = false
                }

            Spacer()
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Step 4: Post Confirm

struct PostConfirmStep: View {
    let image: UIImage?
    let breed: String
    let headline: String
    let style: ArticleStyle
    let palette: StylePalette

    var body: some View {
        VStack {
            Spacer()

            PostCell(
                image: image,
                headline: headline,
                breed: breed,
                location: "London, UK",
                style: style,
                palette: palette
            )
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}
