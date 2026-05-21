import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Your Name", text: $viewModel.userName)
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                Section("Preferences") {
                    Toggle("Notifications", isOn: $viewModel.enableNotifications)
                    Picker("Currency", selection: $viewModel.currency) {
                        Text("USD ($)").tag("USD")
                        Text("EUR (€)").tag("EUR")
                        Text("VND (₫)").tag("VND")
                    }
                    Stepper("Items per page: \(viewModel.itemsPerPage)", value: $viewModel.itemsPerPage, in: 10...50, step: 5)
                }

                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $viewModel.isDarkMode)
                }

                Section("Sorting") {
                    Picker("Sort Order", selection: $viewModel.sortOrder) {
                        Text("Name").tag("name")
                        Text("Price").tag("price")
                        Text("Date").tag("date")
                    }
                }

                Section("File Persistence") {
                    if !viewModel.profileStatus.isEmpty {
                        Text(viewModel.profileStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        ActionButton("Save", systemImage: "square.and.arrow.down", style: .primary) {
                            viewModel.saveToFile()
                        }
                        ActionButton("Load", systemImage: "square.and.arrow.up", style: .secondary) {
                            viewModel.loadFromFile()
                        }
                    }
                }

                Section {
                    Button("Reset All Settings", role: .destructive) {
                        viewModel.resetAll()
                    }
                }

                Section("Stored Data") {
                    Text("Name: \(viewModel.userName)")
                    Text("Email: \(viewModel.email)")
                    Text("Dark Mode: \(viewModel.isDarkMode ? "ON" : "OFF")")
                    Text("Sort: \(viewModel.sortOrder)")
                    Text("Currency: \(viewModel.currency)")
                    Text("Notifications: \(viewModel.enableNotifications ? "ON" : "OFF")")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
