import Foundation

@MainActor
final class ItemViewModel: ObservableObject {
    @Published var items: [ItemDomain] = []
    @Published var searchText = ""
    @Published var todos: [TodoItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let useCase: ItemUseCaseProtocol

    var filteredItems: [ItemDomain] {
        if searchText.isEmpty { return items }
        return useCase.searchItems(query: searchText)
    }
    
    init(useCase: ItemUseCaseProtocol = ItemUseCase()) {
        self.useCase = useCase
        loadItems()
    }

    func item(by id: String) -> ItemDomain? {
        items.first { $0.id == id }
    }

    func loadItems() {
        items = useCase.loadItems()
    }

    func addItem(name: String, desc: String, price: Double, imageUrl: String) {
        useCase.addItem(name: name, desc: desc, price: price, imageUrl: imageUrl)
        loadItems()
    }

    func updateItem(_ item: ItemDomain, name: String, desc: String, price: Double, imageUrl: String) {
        useCase.updateItem(item, name: name, desc: desc, price: price, imageUrl: imageUrl)
        loadItems()
    }

    func deleteItem(_ item: ItemDomain) {
        useCase.deleteItem(item)
        loadItems()
    }

    func fetchTodos() async {
        isLoading = true
        errorMessage = nil
        do {
            todos = try await APIService.shared.fetchTodos()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
