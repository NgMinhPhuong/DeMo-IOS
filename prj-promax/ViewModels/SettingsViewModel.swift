import SwiftUI

final class SettingsViewModel: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode = false
    @AppStorage("sortOrder") var sortOrder = "name"
    @AppStorage("userName") var userName = "Guest"

    @Published var email = "guest@allexceed.co.jp"
    @Published var enableNotifications = true
    @Published var currency = "USD"
    @Published var itemsPerPage = 20
    @Published var profileStatus = ""

    private let fileService = FileManagerService.shared

    init() {
        loadFromFile()
    }

    func saveToFile() {
        let profile = UserProfile(
            displayName: userName,
            email: email,
            preferences: UserPreferences(
                enableNotifications: enableNotifications,
                currency: currency,
                itemsPerPage: itemsPerPage
            )
        )
        do {
            try fileService.saveUserProfile(profile)
            profileStatus = "Saved at \(Date().formatted(date: .omitted, time: .standard))"
        } catch {
            profileStatus = "Save failed: \(error.localizedDescription)"
        }
    }

    func loadFromFile() {
        guard fileService.exists(fileName: "user_profile", subdirectory: "profiles") else { return }
        do {
            let profile = try fileService.loadUserProfile()
            userName = profile.displayName
            email = profile.email
            enableNotifications = profile.preferences.enableNotifications
            currency = profile.preferences.currency
            itemsPerPage = profile.preferences.itemsPerPage
            profileStatus = "Loaded from file"
        } catch {
            profileStatus = "Load failed: \(error.localizedDescription)"
        }
    }

    func resetAll() {
        isDarkMode = false
        sortOrder = "name"
        userName = "Guest"
        email = "guest@allexceed.co.jp"
        enableNotifications = true
        currency = "USD"
        itemsPerPage = 20
        deleteFile()
        profileStatus = "Reset complete"
    }

    func deleteFile() {
        try? fileService.delete(fileName: "user_profile", subdirectory: "profiles")
    }
}
