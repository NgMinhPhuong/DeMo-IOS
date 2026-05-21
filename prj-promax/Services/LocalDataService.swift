import Foundation

enum LocalDataError: LocalizedError {
    case fileNotFound(String)
    case encodingFailed(Error)
    case decodingFailed(Error)
    case writeFailed(Error)
    case readFailed(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name): return "File not found: \(name)"
        case .encodingFailed(let e): return "Encoding failed: \(e.localizedDescription)"
        case .decodingFailed(let e): return "Decoding failed: \(e.localizedDescription)"
        case .writeFailed(let e): return "Write failed: \(e.localizedDescription)"
        case .readFailed(let e): return "Read failed: \(e.localizedDescription)"
        }
    }
}

final class LocalDataService {
    static let shared = LocalDataService()

    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func fileURL(named: String) -> URL {
        documentsURL.appendingPathComponent("\(named).json")
    }

    func save<T: Encodable>(_ object: T, fileName: String) throws {
        let url = fileURL(named: fileName)
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: url, options: .atomic)
        } catch let error as EncodingError {
            throw LocalDataError.encodingFailed(error)
        } catch {
            throw LocalDataError.writeFailed(error)
        }
    }

    func load<T: Decodable>(_ type: T.Type, fileName: String) throws -> T {
        let url = fileURL(named: fileName)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw LocalDataError.fileNotFound(fileName)
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(type, from: data)
        } catch let error as DecodingError {
            throw LocalDataError.decodingFailed(error)
        } catch {
            throw LocalDataError.readFailed(error)
        }
    }

    func delete(fileName: String) throws {
        let url = fileURL(named: fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    func exists(fileName: String) -> Bool {
        FileManager.default.fileExists(atPath: fileURL(named: fileName).path)
    }

    func listSavedFiles() -> [String] {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: documentsURL,
            includingPropertiesForKeys: nil
        ) else { return [] }
        return files
            .filter { $0.pathExtension == "json" }
            .map { $0.deletingPathExtension().lastPathComponent }
    }

    func exportAllItemsJSON(_ items: [ItemDomain]) throws {
        let items = items.map { ExportItem(
            id: $0.id, name: $0.name, desc: $0.desc,
            price: $0.price, imageUrl: $0.imageUrl, createdAt: $0.createdAt
        )}
        try save(items, fileName: "items_export")
    }

    func importItemsJSON() throws -> [ExportItem] {
        try load([ExportItem].self, fileName: "items_export")
    }
}

struct ExportItem: Codable, Identifiable {
    let id: String
    let name: String
    let desc: String
    let price: Double
    let imageUrl: String
    let createdAt: Date
}
