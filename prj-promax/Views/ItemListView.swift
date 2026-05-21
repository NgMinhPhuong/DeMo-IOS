import SwiftUI

enum ItemListSheet: Identifiable {
    case add
    case edit(ItemDomain)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id
        }
    }
}

struct ItemListView: View {
    @ObservedObject var viewModel: ItemViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var showDeleteAlert = false
    @State private var deleteItem: ItemDomain?
    @State private var activeSheet: ItemListSheet?
    @State private var itemsNavPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $itemsNavPath) {
            List {
                ForEach(viewModel.filteredItems) { item in
                    NavigationLink(value: AppRoute.itemDetail(item.id)) {
                        ItemCell(item: item)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteItem = item
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            activeSheet = .edit(item)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            viewModel.deleteItem(item)
                        } label: {
                            Label("Quick Delete", systemImage: "trash.fill")
                        }
                        .tint(.red)
                    }
                }
            }
            .navigationTitle("Items")
            .searchable(text: $viewModel.searchText, prompt: "Search items...")
            .toolbar {
                Button {
                    activeSheet = .add
                } label: {
                    Image(systemName: "plus")
                }
            }
            .alert("Delete Item?", isPresented: $showDeleteAlert, presenting: deleteItem) { item in
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteItem(item)
                }
            } message: { item in
                Text("Are you sure you want to delete \"\(item.name)\"?")
            }
            .onChange(of: coordinator.pendingCommand) { _, cmd in
                guard let cmd else { return }
                switch cmd {
                case .popToRoot:
                    itemsNavPath = NavigationPath()
                case .push(let route):
                    itemsNavPath.append(route)
                case .setPath(let routes):
                    itemsNavPath = NavigationPath(routes)
                case .showAddSheet:
                    activeSheet = .add
                default:
                    break
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .add:
                    AddEditItemView(viewModel: viewModel, editItem: nil)
                case .edit(let item):
                    AddEditItemView(viewModel: viewModel, editItem: item)
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .itemDetail(let id):
                    ItemDetailView(itemID: id, viewModel: viewModel)
                }
            }
        }
    }
}

struct ItemCell: View {
    let item: ItemDomain

    var body: some View {
        HStack(spacing: 12) {
            CustomImageView(url: item.imageUrl, width: 50, height: 50)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text(item.desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Text("$\(item.price, specifier: "%.2f")")
                .font(.subheadline).bold()
                .foregroundColor(.blue)
            
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ItemListView(viewModel: ItemViewModel())
        .environmentObject(AppCoordinator())
}
