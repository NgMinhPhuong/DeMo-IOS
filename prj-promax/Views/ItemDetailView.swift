import SwiftUI

enum DetailSheet: Identifiable {
    case edit(ItemDomain)

    var id: String { item.id }
    var item: ItemDomain {
        switch self {
        case .edit(let item): return item
        }
    }
}

struct ItemDetailView: View {
    let itemID: String
    @ObservedObject var viewModel: ItemViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var showDeleteAlert = false
    @State private var activeSheet: DetailSheet?

    private var item: ItemDomain? {
        viewModel.item(by: itemID)
    }

    var body: some View {
        Group {
            if let item {
                ScrollView {
                    VStack(spacing: 16) {
                        CustomImageView(url: item.imageUrl, width: UIScreen.main.bounds.width - 40, height: 250)
                            .cornerRadius(12)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.name).font(.largeTitle).bold()

                            Text("$\(item.price, specifier: "%.2f")")
                                .font(.title2)
                                .foregroundColor(.blue)

                            Text(item.desc)
                                .font(.body)
                                .foregroundColor(.secondary)

                            Text("Created: \(item.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)

                        HStack(spacing: 16) {
                            Button("Edit") {
                                activeSheet = .edit(item)
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Delete", role: .destructive) {
                                showDeleteAlert = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Detail")
                .navigationBarTitleDisplayMode(.inline)
                .alert("Delete Item?", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        viewModel.deleteItem(item)
                        dismiss()
                    }
                } message: {
                    Text("This action cannot be undone.")
                }
                .sheet(item: $activeSheet) { sheet in
                    AddEditItemView(viewModel: viewModel, editItem: sheet.item)
                }
            } else {
                ContentUnavailableView("Item Not Found", systemImage: "questionmark", description: Text("The item may have been deleted."))
            }
        }
    }
}

#Preview {
    NavigationStack {
        ItemDetailView(itemID: "1", viewModel: ItemViewModel())
            .environmentObject(AppCoordinator())
    }
}
