import SwiftUI

@main
struct prj_promaxApp: App {
    @StateObject private var coordinator: AppCoordinator
    @AppStorage("isDarkMode") private var isDarkMode = false

    init() {
        _coordinator = StateObject(wrappedValue: AppCoordinator())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .onOpenURL { url in
                    coordinator.handleDeepLink(url)
                }
        }
    }
}	
