import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = ItemViewModel()
    @AppStorage("lastSelectedTab") private var lastSelectedTab: Int = 0
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)

            ItemListView(viewModel: viewModel)
                .tabItem { Label("Items", systemImage: "list.bullet") }
                .tag(1)

            GridView(viewModel: viewModel)
                .tabItem { Label("Grid", systemImage: "square.grid.2x2") }
                .tag(2)

            ComponentsGalleryView()
                .tabItem { Label("Components", systemImage: "square.on.square") }
                .tag(3)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(4)
        }
        .onAppear {
            selectedTab = lastSelectedTab
        }
        .onChange(of: selectedTab) { _, newValue in
            lastSelectedTab = newValue
        }
        .onChange(of: coordinator.pendingCommand) { _, cmd in
            guard case .switchTab(let tab) = cmd else { return }
            selectedTab = tab
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
}
