import Foundation

struct TodoItem: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

struct PostItem: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

final class APIService {
    static let shared = APIService()	
    private let baseURL = "https://jsonplaceholder.typicode.com"

    func fetchTodos() async throws -> [TodoItem] {
        let url = URL(string: "\(baseURL)/todos")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([TodoItem].self, from: data)
    }

    func fetchPosts() async throws -> [PostItem] {
        let url = URL(string: "\(baseURL)/posts")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([PostItem].self, from: data)
    }
}
