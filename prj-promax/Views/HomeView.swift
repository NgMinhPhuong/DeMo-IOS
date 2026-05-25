import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = ItemViewModel()
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var showAlert = false
    @State private var showSheet = false
    @State private var showConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    CustomImageView(
                        url: "https://picsum.photos/400/200",
                        width: UIScreen.main.bounds.width - 40,
                        height: 200
                    )
                    .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Welcome to Demo App")
                            .font(.title2).bold()

                        Text("This app demonstrates: List, Grid, TabView, Navigation, Realm, API calls, async/await, UserDefaults, and more.")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    HStack(spacing: 16) {
                        Button("Sheet") { showSheet = true }
                            .buttonStyle(.borderedProminent)
                        Button("Alert") { showAlert = true }
                            
                            .buttonStyle(.bordered)
                        Button("Confirm") { showConfirmation = true }
                       
                            .buttonStyle(.bordered)
                    }

                    VStack(spacing: 12) {
                        Text("Deep Link Simulations").font(.headline)

                        HStack(spacing: 12) {
                            ActionButton("Items", systemImage: "list.bullet", style: .primary) {
                                coordinator.execute(.switchTab(1))
                            }
                            ActionButton("Grid", systemImage: "square.grid.2x2", style: .secondary) {
                                coordinator.execute(.switchTab(2))
                            }
                        }
                        .padding(.horizontal)

                        HStack(spacing: 12) {
                            ActionButton("Settings", systemImage: "gearshape", style: .secondary) {
                                coordinator.execute(.switchTab(4))
                            }
                            ActionButton("Components", systemImage: "square.on.square", style: .secondary) {
                                coordinator.execute(.switchTab(3))
                            }
                        }
                        .padding(.horizontal)
                    }

                    if viewModel.isLoading {
                        ProgressView("Loading API data...")
                    }

                    if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red).font(.caption)
                    }

                    if !viewModel.todos.isEmpty {
                        VStack(alignment: .leading) {
                            Text("API Sample (Todos):").font(.headline).padding(.horizontal)
                            ForEach(viewModel.todos.prefix(5)) { todo in
                                HStack {
                                    Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(todo.completed ? .green : .gray)
                                    Text(todo.title).font(.caption)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                Divider()
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .task { await viewModel.fetchTodos() }
            .alert("Alert Demo", isPresented: $showAlert) {
                Button("OK") { showAlert = false }
            } message: {
                Text("This is a basic alert in SwiftUI.")
            }
            .confirmationDialog("Choose Action", isPresented: $showConfirmation) {
                Button("Option A") {}
                Button("Option B") {}
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("ConfirmationDialog demo — select an option.")
            }
            .sheet(isPresented: $showSheet) {
                NavigationStack {
                    VStack(spacing: 16) {
                        Text("Sheet Content")
                            .font(.title)
                        Text("This is a modal sheet presented from Home.")
                    }
                    .padding()
                    .toolbar { Button("Close") { showSheet = false } }
                }
            }
        }
    }
}
 
#Preview {
    HomeView()
        .environmentObject(AppCoordinator())
}
