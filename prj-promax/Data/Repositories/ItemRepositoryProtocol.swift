import Foundation

protocol ItemRepositoryProtocol {
    func getAll() -> [ItemDomain]
    func get(by id: String) -> ItemDomain?
    func add(_ item: ItemDomain)
    func update(_ item: ItemDomain)
    func delete(by id: String)
    func search(query: String) -> [ItemDomain]
}
