import Foundation

struct ItemDomain: Identifiable, Hashable {
    let id: String
    var name: String
    var desc: String
    var price: Double
    var imageUrl: String
    var createdAt: Date

    init(id: String = UUID().uuidString, name: String, desc: String, price: Double, imageUrl: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.desc = desc
        self.price = price
        self.imageUrl = imageUrl
        self.createdAt = createdAt
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
