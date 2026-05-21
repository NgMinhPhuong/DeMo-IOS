import Foundation

protocol ItemUseCaseProtocol {
    func loadItems() -> [ItemDomain]
    func searchItems(query: String) -> [ItemDomain]
    func addItem(name: String, desc: String, price: Double, imageUrl: String)
    func updateItem(_ item: ItemDomain, name: String, desc: String, price: Double, imageUrl: String)
    func deleteItem(_ item: ItemDomain)
}

final class ItemUseCase: ItemUseCaseProtocol {
    private let repository: ItemRepositoryProtocol

    init(repository: ItemRepositoryProtocol = ItemRepositoryImpl()) {
        self.repository = repository
    }

    func loadItems() -> [ItemDomain] {
        repository.getAll()
    }

    func searchItems(query: String) -> [ItemDomain] {
        repository.search(query: query)
    }

    func addItem(name: String, desc: String, price: Double, imageUrl: String) {
        let item = ItemDomain(name: name, desc: desc, price: price, imageUrl: imageUrl)
        repository.add(item)
    }

    func updateItem(_ item: ItemDomain, name: String, desc: String, price: Double, imageUrl: String) {
        var updated = item
        updated.name = name
        updated.desc = desc
        updated.price = price
        updated.imageUrl = imageUrl
        repository.update(updated)
    }

    func deleteItem(_ item: ItemDomain) {
        repository.delete(by: item.id)
    }
}
