import SwiftUI

/// The onboarding experience — a fake text conversation with Pawrez Hilton.
///
/// Loads conversation steps from JSON, animates messages in with staggered delays,
/// and handles user input (text, permissions, photo picker) between steps.
struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var conversation = OnboardingConversation.load()
    @State private var currentStepIndex: Int = 0
    @State private var visibleMessages: [ChatMessage] = []
    @State private var isAnimatingMessages = false
    @State private var inputText: String = ""
    @State private var inputEnabled = false
    @State private var showNewContactModal = true
    @State private var username: String = ""
    private let permissionsManager = PermissionsManager()

    // Modal intro animation stages
    @State private var modalBackgroundOpacity: Double = 0
    @State private var modalTitleScale: CGFloat = 0.3
    @State private var modalTitleOpacity: Double = 0
    @State private var modalCardScale: CGFloat = 0.5
    @State private var modalCardOpacity: Double = 0
    @State private var modalHintOpacity: Double = 0

    private var currentStep: ConversationStep? {
        guard currentStepIndex < conversation.conversation.count else { return nil }
        return conversation.conversation[currentStepIndex]
    }

    /// Groups consecutive `.pawrez` messages by stepId for rendering in containers,
    /// while keeping user messages as standalone items.
    private var groupedMessages: [GroupedChatItem] {
        var result: [GroupedChatItem] = []

        for message in visibleMessages {
            switch message.type {
            case .pawrez(let text, let stepId):
                // Try to append to the last group if same stepId
                if let lastIndex = result.indices.last,
                   case .pawrezGroup(let texts, let existingStepId) = result[lastIndex].type,
                   existingStepId == stepId {
                    result[lastIndex] = GroupedChatItem(
                        id: existingStepId,
                        type: .pawrezGroup(texts + [text], stepId: existingStepId)
                    )
                } else {
                    result.append(GroupedChatItem(
                        id: stepId,
                        type: .pawrezGroup([text], stepId: stepId)
                    ))
                }

            case .userChip(let text):
                result.append(GroupedChatItem(
                    id: message.id.uuidString,
                    type: .userChip(text)
                ))

            case .userImage(let image):
                result.append(GroupedChatItem(
                    id: message.id.uuidString,
                    type: .userImage(image)
                ))
            }
        }

        return result
    }

    var body: some View {
        ZStack {
            AppColor.Background.primary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Chat header
                chatHeader
                    .opacity(showNewContactModal ? 0.3 : 1)

                // Messages scroll area
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 20) {
                            ForEach(groupedMessages) { item in
                                groupedMessageView(item)
                                    .id(item.id)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                    .defaultScrollAnchor(.bottom)
                    .opacity(showNewContactModal ? 0 : 1)
                    .onChange(of: visibleMessages.count) { _, _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(groupedMessages.last?.id, anchor: .bottom)
                        }
                    }
                }

                // Input bar — always visible
                ChatInputBar(
                    text: $inputText,
                    placeholder: currentStep?.action.placeholder ?? "Type a message...",
                    isEnabled: inputEnabled
                ) {
                    handleSend()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .opacity(showNewContactModal ? 0.3 : 1)
            }

            // New Contact modal overlay
            if showNewContactModal {
                newContactModal
                    .zIndex(10)
            }
        }
        // Allow keyboard to push content up
        .onAppear {
            playModalIntro()
        }
        .onTapGesture {
            if showNewContactModal {
                dismissModalAndStart()
            }
        }
    }

    // MARK: - Chat Header

    private var chatHeader: some View {
        VStack(spacing: 6) {
            ChatAvatar.pawrez(size: 48)
            Text("Pawrez Hilton")
                .font(AppFont.caption.bold())
                .foregroundStyle(AppColor.Label.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppColor.Border.default)
                .frame(height: 1)
        }
    }

    // MARK: - New Contact Modal

    private var newContactModal: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                // Title — slams in
                Text("NEW CONTACT!")
                    .font(AppFont.hero)
                    .foregroundStyle(AppColor.Label.primary)
                    .scaleEffect(modalTitleScale)
                    .opacity(modalTitleOpacity)

                // Contact card — bounces up
                VStack(spacing: 12) {
                    ChatAvatar.pawrez(size: 72)

                    Text("Pawrez Hilton")
                        .font(AppFont.title.bold())
                        .foregroundStyle(AppColor.Label.primary)

                    Text("Just accepted your contact request")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.Label.secondary)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColor.Background.secondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColor.Border.default, lineWidth: 1)
                )
                .scaleEffect(modalCardScale)
                .opacity(modalCardOpacity)

                // Hint — fades in last
                Text("Tap anywhere to chat")
                    .font(AppFont.caption.bold())
                    .foregroundStyle(AppColor.Fill.accent)
                    .opacity(modalHintOpacity)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
        .opacity(modalBackgroundOpacity)
    }

    // MARK: - Grouped Message View

    @ViewBuilder
    private func groupedMessageView(_ item: GroupedChatItem) -> some View {
        switch item.type {
        case .pawrezGroup(let texts, _):
            PawrezMessageContainer(showAvatar: true) {
                ForEach(Array(texts.enumerated()), id: \.offset) { _, text in
                    ChatBubble(text: text, sender: .pawrez)
                }
            }

        case .userChip(let text):
            UserMessageContainer(username: username, showAvatar: !username.isEmpty) {
                ChatUsernameChip(username: text)
            }

        case .userImage(let image):
            UserMessageContainer(username: username, showAvatar: !username.isEmpty) {
                ChatImageBubble(image: image)
            }
        }
    }

    // MARK: - Modal Intro Animation

    private func playModalIntro() {
        // Stage 1: Background fades in
        withAnimation(.easeOut(duration: 0.4)) {
            modalBackgroundOpacity = 1
        }

        // Stage 2: Title slams in with a heavy impact
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.5, blendDuration: 0)) {
                modalTitleScale = 1.0
                modalTitleOpacity = 1.0
            }
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }

        // Stage 3: Card bounces up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                modalCardScale = 1.0
                modalCardOpacity = 1.0
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }

        // Stage 4: Hint fades in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.5)) {
                modalHintOpacity = 1.0
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    // MARK: - Actions

    private func dismissModalAndStart() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        withAnimation(.easeOut(duration: 0.4)) {
            showNewContactModal = false
        }
        // Start first step after a short pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            animateCurrentStep()
        }
    }

    private func animateCurrentStep() {
        guard let step = currentStep else { return }

        isAnimatingMessages = true

        let messages = step.pawrezMessages
        let isLastStep = step.action.type == .complete

        var delay: TimeInterval = 0
        let baseDelay: TimeInterval = 0.4
        let perCharDelay: TimeInterval = 0.012

        for (index, text) in messages.enumerated() {
            let messageDelay = baseDelay + Double(min(text.count, 80)) * perCharDelay

            delay += (index == 0) ? 0.3 : messageDelay

            let capturedDelay = delay
            let capturedIndex = index

            DispatchQueue.main.asyncAfter(deadline: .now() + capturedDelay) {
                withAnimation(.easeOut(duration: 0.25)) {
                    visibleMessages.append(ChatMessage(
                        type: .pawrez(text, stepId: step.id)
                    ))
                }

                // Soft tap haptic for each message
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()

                let isLast = capturedIndex == messages.count - 1
                if isLast {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isAnimatingMessages = false

                        if isLastStep {
                            // Final success haptic
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                onComplete()
                            }
                        } else if step.action.type == .textInput {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                inputEnabled = true
                            }
                        } else if step.action.type == .permission || step.action.type == .photoPicker {
                            handlePermissionStep(step)
                        }
                    }
                }
            }
        }
    }

    private func handleSend() {
        guard let step = currentStep else { return }
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // Haptic on send
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if step.id == "welcome" {
            username = trimmed
        }

        withAnimation(.easeOut(duration: 0.25)) {
            visibleMessages.append(ChatMessage(
                type: .userChip(trimmed)
            ))
            inputEnabled = false
            inputText = ""
        }

        currentStepIndex += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            animateCurrentStep()
        }
    }

    private func handlePermissionStep(_ step: ConversationStep) {
        Task {
            // Small delay before showing the system alert
            try? await Task.sleep(for: .milliseconds(800))

            let result = await requestPermission(for: step.action.permissionType)

            await MainActor.run {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()

                if result == .granted {
                    // Permission granted — show user response and advance
                    if let response = step.userResponse {
                        withAnimation(.easeOut(duration: 0.25)) {
                            appendUserResponse(response)
                        }
                    }

                    currentStepIndex += 1

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        animateCurrentStep()
                    }
                } else {
                    // Permission denied — show denied messages then advance
                    handleDenied(step: step)
                }
            }
        }
    }

    private func requestPermission(for permissionType: String?) async -> PermissionsManager.PermissionResult {
        switch permissionType {
        case "camera":
            return await permissionsManager.requestCamera()
        case "location":
            return await permissionsManager.requestLocation()
        case "photoLibrary":
            return await permissionsManager.requestPhotoLibrary()
        default:
            return .granted
        }
    }

    private func handleDenied(step: ConversationStep) {
        guard let denied = step.onDenied else {
            // No denied fallback — just advance
            currentStepIndex += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                animateCurrentStep()
            }
            return
        }

        // Show denied response chip
        withAnimation(.easeOut(duration: 0.25)) {
            visibleMessages.append(ChatMessage(
                type: .userChip("Nah, I'm good")
            ))
        }

        // Animate Pawrez's denied messages
        isAnimatingMessages = true
        var delay: TimeInterval = 0.6
        let baseDelay: TimeInterval = 0.4
        let perCharDelay: TimeInterval = 0.012

        for (index, text) in denied.pawrezMessages.enumerated() {
            let messageDelay = baseDelay + Double(min(text.count, 80)) * perCharDelay
            delay += (index == 0) ? 0.3 : messageDelay

            let capturedDelay = delay
            let capturedIndex = index

            DispatchQueue.main.asyncAfter(deadline: .now() + capturedDelay) {
                withAnimation(.easeOut(duration: 0.25)) {
                    visibleMessages.append(ChatMessage(
                        type: .pawrez(text, stepId: "\(step.id)_denied")
                    ))
                }
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()

                if capturedIndex == denied.pawrezMessages.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isAnimatingMessages = false
                        currentStepIndex += 1

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            animateCurrentStep()
                        }
                    }
                }
            }
        }
    }

    private func appendUserResponse(_ response: UserResponse) {
        switch response.type {
        case .chip:
            visibleMessages.append(ChatMessage(
                type: .userChip(response.value ?? "Done.")
            ))
        case .image:
            visibleMessages.append(ChatMessage(
                type: .userImage(Image(systemName: "person.crop.square.fill"))
            ))
        case .usernameChip:
            visibleMessages.append(ChatMessage(
                type: .userChip(response.value ?? username)
            ))
        }
    }
}

// MARK: - Chat Message Model (flat list)

struct ChatMessage: Identifiable {
    let id = UUID()
    let type: ChatMessageType
}

enum ChatMessageType {
    case pawrez(String, stepId: String)
    case userChip(String)
    case userImage(Image)
}

// MARK: - Grouped Chat Item (computed for rendering)

struct GroupedChatItem: Identifiable {
    let id: String
    let type: GroupedChatItemType
}

enum GroupedChatItemType {
    case pawrezGroup([String], stepId: String)
    case userChip(String)
    case userImage(Image)
}
