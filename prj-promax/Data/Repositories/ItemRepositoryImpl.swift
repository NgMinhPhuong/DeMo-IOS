import Foundation

final class ItemRepositoryImpl: ItemRepositoryProtocol {
    private let realm = RealmService.shared

    func getAll() -> [ItemDomain] {
        let items: [RealmItem] = realm.getAll()
        return items.map { $0.toDomain() }
    }

    func get(by id: String) -> ItemDomain? {
        let item: RealmItem? = realm.getLive(by: id)
        return item?.toDomain()
    }

    func add(_ item: ItemDomain) {
        let realmItem = item.toRealm()
        realm.add(realmItem)
    }

    func update(_ item: ItemDomain) {
        guard let live: RealmItem = realm.getLive(by: item.id) else { return }
        realm.update {
            live.name = item.name
            live.desc = item.desc
            live.price = item.price
            live.imageUrl = item.imageUrl
        }
    }

    func delete(by id: String) {
        guard let live: RealmItem = realm.getLive(by: id) else { return }
        realm.delete(live)
    }

    func search(query: String) -> [ItemDomain] {
        let items: [RealmItem] = realm.getAll()
        return items
            .map { $0.toDomain() }
            .filter {
                query.isEmpty ||
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.desc.localizedCaseInsensitiveContains(query)
            }
    }
}
