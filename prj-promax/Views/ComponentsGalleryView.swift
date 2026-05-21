import SwiftUI

struct ComponentsGalleryView: View {
    @StateObject private var settings = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        ProfileAvatarView(name: settings.userName, url: nil, size: 72)
                        Text(settings.userName)
                            .font(.title2).bold()
                        if !settings.email.isEmpty {
                            Text(settings.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } header: {
                    SectionHeaderView(title: "Profile", count: nil)
                }

                Section {
                    HStack {
                        StatCardView(title: "Items/Page", value: "\(settings.itemsPerPage)", icon: "list.number", color: .blue)
                        StatCardView(title: "Currency", value: settings.currency, icon: "dollarsign.circle", color: .green)
                        StatCardView(title: "Dark Mode", value: settings.isDarkMode ? "ON" : "OFF", icon: "moon.circle", color: .orange)
                    }
                } header: {
                    SectionHeaderView(title: "Stats", count: 3)
                }

                Section {
                    InfoRowView(label: "Name", value: settings.userName, icon: "person")
                    InfoRowView(label: "Email", value: settings.email, icon: "envelope")
                    InfoRowView(label: "Notifications", value: settings.enableNotifications ? "Enabled" : "Disabled", icon: "bell")
                    InfoRowView(label: "Sort Order", value: settings.sortOrder.capitalized, icon: "arrow.up.arrow.down")
                } header: {
                    SectionHeaderView(title: "Info Rows", count: 4)
                }

                Section {
                    HStack(spacing: 8) {
                        BadgeView(text: "Active", style: .success)
                        BadgeView(text: "Pending", style: .warning)
                        BadgeView(text: "Blocked", style: .danger)
                        BadgeView(text: "Info", style: .info)
                    }
                } header: {
                    SectionHeaderView(title: "Badges", count: 4)
                }

                Section {
                    RoundedCardView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rounded Card Example")
                                .font(.headline)
                            Text("This is a reusable card container with padding, background, corner radius, and shadow.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            PriceText(price: 29.99, font: .title2, color: .blue)
                        }
                    }
                } header: {
                    SectionHeaderView(title: "Rounded Card + Price", count: nil)
                }

                Section {
                    ActionButton("Primary", systemImage: "hand.thumbsup", style: .primary, action: {})
                    ActionButton("Secondary", systemImage: "gearshape", style: .secondary, action: {})
                    ActionButton("Delete", systemImage: "trash", style: .destructive, action: {})
                } header: {
                    SectionHeaderView(title: "Action Buttons", count: 3)
                }

                Section {
                    EmptyStateView(title: "No Items", message: "Your list is empty", systemImage: "tray")
                } header: {
                    SectionHeaderView(title: "Empty State", count: nil)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Components")
        }
    }
}

#Preview {
    ComponentsGalleryView()
}
