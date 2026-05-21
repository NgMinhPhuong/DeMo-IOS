import SwiftUI

struct GridView: View {
    @ObservedObject var viewModel: ItemViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var gridNavPath = NavigationPath()

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        NavigationStack(path: $gridNavPath) {
            ScrollView {
                if viewModel.items.isEmpty {
                    ContentUnavailableView(
                        "No Items",
                        systemImage: "square.grid.2x2",
                        description: Text("Add items from the Items tab to see them here.")
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.items) { item in
                            NavigationLink(value: AppRoute.itemDetail(item.id)) {
                                GridCell(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                }
            }
            .navigationTitle("Grid")
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .itemDetail(let id):
                    ItemDetailView(itemID: id, viewModel: viewModel)
                }
            }
            .onChange(of: coordinator.pendingCommand) { _, cmd in
                guard let cmd else { return }
                switch cmd {
                case .popToRoot:
                    gridNavPath = NavigationPath()
                case .push(let route):
                    gridNavPath.append(route)
                case .setPath(let routes):
                    gridNavPath = NavigationPath(routes)
                default:
                    break
                }
            }
        }
    }
}

struct GridCell: View {
    let item: ItemDomain

    var body: some View {
        VStack(spacing: 8) {
            CustomImageView(url: item.imageUrl, width: .infinity, height: 120)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    GridView(viewModel: ItemViewModel())
        .environmentObject(AppCoordinator())
}
