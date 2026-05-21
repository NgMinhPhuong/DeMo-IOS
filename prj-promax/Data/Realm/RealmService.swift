import Foundation
import RealmSwift

final class RealmService {
    static let shared = RealmService()
    private var realm: Realm

    private init() {
        realm = try! Realm()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }

    func getAll<T: Object>() -> [T] {
        Array(realm.objects(T.self).freeze())
    }

    func getLive<T: Object>(by id: String) -> T? {
        realm.object(ofType: T.self, forPrimaryKey: id)
    }

    func add<T: Object>(_ object: T) {
        try! realm.write { realm.add(object) }
    }

    func update(_ block: @escaping () -> Void) {
        try! realm.write { block() }
    }

    func delete<T: Object>(_ object: T) {
        try! realm.write { realm.delete(object) }
    }

    func deleteAll<T: Object>(_ type: T.Type) {
        try! realm.write { realm.delete(realm.objects(type)) }
    }
}
