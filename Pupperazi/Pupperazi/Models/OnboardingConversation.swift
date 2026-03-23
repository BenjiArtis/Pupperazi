import Foundation

/// The full onboarding conversation, loaded from JSON.
struct OnboardingConversation: Codable {
    let conversation: [ConversationStep]
}

/// A single step in the onboarding conversation.
struct ConversationStep: Codable, Identifiable {
    let id: String
    let pawrezMessages: [String]
    let action: StepAction
    let userResponse: UserResponse?
    let onDenied: DeniedFallback?
}

/// What the app should do after Pawrez's messages are shown.
struct StepAction: Codable {
    let type: ActionType
    var placeholder: String?
    var inputFormat: String?
    var keyboardType: String?
    var permissionType: String?

    enum ActionType: String, Codable {
        case textInput
        case permission
        case retryPermission
        case photoPicker
        case complete
        case skip
    }
}

/// How the user's response is displayed in the chat.
struct UserResponse: Codable {
    let type: ResponseType
    let valueFrom: String
    var value: String?

    enum ResponseType: String, Codable {
        case usernameChip
        case chip
        case image
    }
}

/// Fallback messages + action if the user denies a permission.
struct DeniedFallback: Codable {
    let pawrezMessages: [String]
    let action: StepAction
}

// MARK: - Loader

extension OnboardingConversation {
    /// Loads the conversation from the bundled JSON file.
    static func load() -> OnboardingConversation {
        guard let url = Bundle.main.url(forResource: "onboarding_conversation", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let conversation = try? JSONDecoder().decode(OnboardingConversation.self, from: data)
        else {
            fatalError("Failed to load onboarding_conversation.json from bundle")
        }
        return conversation
    }
}
