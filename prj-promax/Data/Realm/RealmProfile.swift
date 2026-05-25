import Foundation
import RealmSwift

class RealmProfile: Object {
    @Persisted(primaryKey: true) var id: String = "user_profile"
    @Persisted var avatarFilename: String = ""
}
