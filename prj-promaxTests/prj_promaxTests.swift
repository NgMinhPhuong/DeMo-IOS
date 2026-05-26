import XCTest
@testable import prj_promax

// MARK: - Mocks

final class MockRepository: ItemRepositoryProtocol {
    private var storage: [ItemDomain] = []

    func getAll() -> [ItemDomain] { storage }
    func get(by id: String) -> ItemDomain? { storage.first { $0.id == id } }
    func add(_ item: ItemDomain) { storage.append(item) }
    func update(_ item: ItemDomain) {
        delete(by: item.id)
        storage.append(item)
    }
    func delete(by id: String) { storage.removeAll { $0.id == id } }
    func search(query: String) -> [ItemDomain] {
        if query.isEmpty { return storage }
        return storage.filter { $0.name.localizedCaseInsensitiveContains(query) || $0.desc.localizedCaseInsensitiveContains(query) }
    }
}

// MARK: - ItemDomain Tests

final class ItemDomainTests: XCTestCase {
    func test_init_assignsProperties() {
        let date = Date()
        let item = ItemDomain(id: "1", name: "Test", desc: "Description", price: 9.99, imageUrl: "img.jpg", createdAt: date)
        XCTAssertEqual(item.id, "1")
        XCTAssertEqual(item.name, "Test")
        XCTAssertEqual(item.desc, "Description")
        XCTAssertEqual(item.price, 9.99)
        XCTAssertEqual(item.imageUrl, "img.jpg")
        XCTAssertEqual(item.createdAt, date)
    }

    func test_hash_usesId() {
        let b = ItemDomain(id: "1", name: "Y", desc: "", price: 0, imageUrl: "")
        XCTAssertEqual(b.hashValue, b.hashValue)
        XCTAssertEqual(b, b)
    }

    func test_init_generatesUUID_whenIdNotProvided() {
        let item = ItemDomain(name: "NoID", desc: "", price: 0, imageUrl: "")
        XCTAssertFalse(item.id.isEmpty)
    }
}

// MARK: - UserProfile & UserPreferences Tests

final class UserProfileTests: XCTestCase {
    func test_codableRoundTrip() throws {
        let profile = UserProfile(
            id: "u1",
            displayName: "Alice",
            email: "alice@example.com",
            avatarURL: "avatar.png",
            preferences: UserPreferences(enableNotifications: false, currency: "VND", itemsPerPage: 10),
            createdAt: Date(timeIntervalSince1970: 0)
        )
        let data = try JSONEncoder().encode(profile)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: data)
        XCTAssertEqual(decoded.id, profile.id)
        XCTAssertEqual(decoded.displayName, profile.displayName)
        XCTAssertEqual(decoded.email, profile.email)
        XCTAssertEqual(decoded.preferences.enableNotifications, false)
        XCTAssertEqual(decoded.preferences.currency, "VND")
        XCTAssertEqual(decoded.preferences.itemsPerPage, 10)
    }

    func test_preferences_defaultValues() {
        let prefs = UserPreferences()
        XCTAssertTrue(prefs.enableNotifications)
        XCTAssertEqual(prefs.currency, "USD")
        XCTAssertEqual(prefs.itemsPerPage, 20)
    }
}

// MARK: - AppCoordinator Tests

final class AppCoordinatorTests: XCTestCase {
    func test_execute_setsPendingCommand() {
        let coordinator = AppCoordinator()
        coordinator.execute(.switchTab(2))
        XCTAssertEqual(coordinator.pendingCommand, .switchTab(2))
    }

    func test_deepLink_home_setsCorrectCommands() {
        let coordinator = AppCoordinator()
        let url = URL(string: "prjpromax://home")!
        coordinator.handleDeepLink(url)
        XCTAssertEqual(coordinator.pendingCommand, .switchTab(0))
    }

    func test_deepLink_itemWithId_setsPushCommand() {
        let coordinator = AppCoordinator()
        let url = URL(string: "prjpromax://item/abc-123")!
        coordinator.handleDeepLink(url)
        XCTAssertEqual(coordinator.pendingCommand, .switchTab(1))
    }

    func test_deepLink_add_setsShowAddSheet() {
        let coordinator = AppCoordinator()
        let url = URL(string: "prjpromax://add")!
        coordinator.handleDeepLink(url)
        XCTAssertEqual(coordinator.pendingCommand, .switchTab(1))
    }

    func test_deepLink_invalidScheme_ignored() {
        let coordinator = AppCoordinator()
        let url = URL(string: "https://home")!
        coordinator.handleDeepLink(url)
        XCTAssertNil(coordinator.pendingCommand)
    }

    func test_deepLink_invalidHost_ignored() {
        let coordinator = AppCoordinator()
        let url = URL(string: "prjpromax://unknown")!
        coordinator.handleDeepLink(url)
        XCTAssertNil(coordinator.pendingCommand)
    }
}

// MARK: - ItemUseCase Tests

final class ItemUseCaseTests: XCTestCase {
    func test_addItem_storesInRepository() {
        let repo = MockRepository()
        let useCase = ItemUseCase(repository: repo)
        useCase.addItem(name: "New", desc: "Desc", price: 5.0, imageUrl: "img.png")
        XCTAssertEqual(repo.getAll().count, 1)
        XCTAssertEqual(repo.getAll().first?.name, "New")
    }

    func test_deleteItem_removesFromRepository() {
        let repo = MockRepository()
        let useCase = ItemUseCase(repository: repo)
        useCase.addItem(name: "A", desc: "", price: 0, imageUrl: "")
        let item = repo.getAll().first!
        useCase.deleteItem(item)
        XCTAssertTrue(repo.getAll().isEmpty)
    }

    func test_loadItems_returnsAllItems() {
        let repo = MockRepository()
        repo.add(ItemDomain(name: "A", desc: "", price: 0, imageUrl: ""))
        repo.add(ItemDomain(name: "B", desc: "", price: 0, imageUrl: ""))
        let useCase = ItemUseCase(repository: repo)
        XCTAssertEqual(useCase.loadItems().count, 2)
    }

    func test_updateItem_modifiesFields() {
        let repo = MockRepository()
        let useCase = ItemUseCase(repository: repo)
        useCase.addItem(name: "Old", desc: "Old desc", price: 1, imageUrl: "old.png")
        let item = repo.getAll().first!
        useCase.updateItem(item, name: "Updated", desc: "Updated desc", price: 99, imageUrl: "new.png")
        let updated = repo.getAll().first!
        XCTAssertEqual(updated.name, "Updated")
        XCTAssertEqual(updated.price, 99)
    }

    func test_searchItems_filtersByName() {
        let repo = MockRepository()
        repo.add(ItemDomain(name: "Apple", desc: "Fruit", price: 0, imageUrl: ""))
        repo.add(ItemDomain(name: "Banana", desc: "Yellow", price: 0, imageUrl: ""))
        let useCase = ItemUseCase(repository: repo)
        let results = useCase.searchItems(query: "Apple")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Apple")
    }
}

// MARK: - ItemViewModel Tests

@MainActor
final class ItemViewModelTests: XCTestCase {
    func test_init_loadsItems() {
        let repo = MockRepository()
        repo.add(ItemDomain(name: "Preloaded", desc: "", price: 0, imageUrl: ""))
        let useCase = ItemUseCase(repository: repo)
        let vm = ItemViewModel(useCase: useCase)
        XCTAssertEqual(vm.items.count, 1)
    }

    func test_addItem_updatesItems() {
        let repo = MockRepository()
        let useCase = ItemUseCase(repository: repo)
        let vm = ItemViewModel(useCase: useCase)
        vm.addItem(name: "Added", desc: "Desc", price: 10, imageUrl: "img.jpg")
        XCTAssertEqual(vm.items.count, 1)
        XCTAssertEqual(vm.items.first?.name, "Added")
    }

    func test_deleteItem_updatesItems() {
        let repo = MockRepository()
        let useCase = ItemUseCase(repository: repo)
        let vm = ItemViewModel(useCase: useCase)
        vm.addItem(name: "ToDelete", desc: "", price: 0, imageUrl: "")
        let item = vm.items.first!
        vm.deleteItem(item)
        XCTAssertTrue(vm.items.isEmpty)
    }

    func test_filteredItems_withSearchText() {
        let repo = MockRepository()
        let useCase = ItemUseCase(repository: repo)
        let vm = ItemViewModel(useCase: useCase)
        vm.addItem(name: "iPhone", desc: "Phone", price: 999, imageUrl: "")
        vm.addItem(name: "iPad", desc: "Tablet", price: 799, imageUrl: "")
        vm.searchText = "iPhone"
        XCTAssertEqual(vm.filteredItems.count, 1)
        XCTAssertEqual(vm.filteredItems.first?.name, "iPhone")
    }

    func test_filteredItems_emptySearch_returnsAll() {
        let repo = MockRepository()
        let useCase = ItemUseCase(repository: repo)
        let vm = ItemViewModel(useCase: useCase)
        vm.addItem(name: "A", desc: "", price: 0, imageUrl: "")
        vm.addItem(name: "B", desc: "", price: 0, imageUrl: "")
        vm.searchText = ""
        XCTAssertEqual(vm.filteredItems.count, 2)
    }

    func test_itemById_returnsCorrectItem() {
        let repo = MockRepository()
        let useCase = ItemUseCase(repository: repo)
        let vm = ItemViewModel(useCase: useCase)
        vm.addItem(name: "Target", desc: "", price: 0, imageUrl: "")
        let id = vm.items.first!.id
        let found = vm.item(by: id)
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.name, "Target")
    }

    func test_itemById_notFound_returnsNil() {
        let vm = ItemViewModel(useCase: ItemUseCase(repository: MockRepository()))
        XCTAssertNil(vm.item(by: "nonexistent"))
    }
}
