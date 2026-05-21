import Foundation
import RealmSwift

class RealmItem: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var desc: String = ""
    @Persisted var price: Double = 0
    @Persisted var imageUrl: String = ""
    @Persisted var createdAt: Date = Date()

    convenience init(name: String, desc: String, price: Double, imageUrl: String) {
        self.init()
        self.name = name
        self.desc = desc
        self.price = price
        self.imageUrl = imageUrl
    }
}

extension RealmItem {
    func toDomain() -> ItemDomain {
        ItemDomain(id: id, name: name, desc: desc, price: price, imageUrl: imageUrl, createdAt: createdAt)
    }
}

extension ItemDomain {
    func toRealm() -> RealmItem {
        let item = RealmItem()
        item.id = id
        item.name = name
        item.desc = desc
        item.price = price
        item.imageUrl = imageUrl
        item.createdAt = createdAt
        return item
    }
}
