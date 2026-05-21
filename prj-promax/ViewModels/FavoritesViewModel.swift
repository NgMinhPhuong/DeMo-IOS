import SwiftUI

final class FavoritesViewModel: ObservableObject {
    @AppStorage("favorite_ids") private var favoriteIDsString: String = ""

    private var favoriteIDs: Set<String> {
        get {
            Set(favoriteIDsString
                .split(separator: ",")
                .map(String.init)
                .filter { !$0.isEmpty }
            )
        }
        set {
            favoriteIDsString = newValue.joined(separator: ",")
        }
    }

    func isFavorite(_ itemID: String) -> Bool {
        favoriteIDs.contains(itemID)
    }

    func toggle(_ itemID: String) {
        var ids = favoriteIDs
        if ids.contains(itemID) {
            ids.remove(itemID)
        } else {
            ids.insert(itemID)
        }
        favoriteIDs = ids
    }

    var allFavoriteIDs: [String] {
        Array(favoriteIDs)
    }

    var count: Int {
        favoriteIDs.count
    }
}
