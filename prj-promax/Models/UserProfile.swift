import Foundation

struct UserProfile: Codable, Identifiable {
    var id: String
    var displayName: String
    var email: String
    var avatarURL: String
    var preferences: UserPreferences
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        displayName: String = "",
        email: String = "",
        avatarURL: String = "",
        preferences: UserPreferences = .init(),
        createdAt: Date = .init()
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.avatarURL = avatarURL
        self.preferences = preferences
        self.createdAt = createdAt
    }
}

struct UserPreferences: Codable {
    var enableNotifications: Bool
    var currency: String
    var itemsPerPage: Int

    init(enableNotifications: Bool = true, currency: String = "USD", itemsPerPage: Int = 20) {
        self.enableNotifications = enableNotifications
        self.currency = currency
        self.itemsPerPage = itemsPerPage
    }
}
