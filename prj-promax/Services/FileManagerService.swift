import Foundation

enum FileManagerError: LocalizedError {
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

final class FileManagerService {
    static let shared = FileManagerService()

    private let fm: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private var documentsURL: URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var supportURL: URL {
        fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }

    init() {
        fm = FileManager.default
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder = JSONDecoder()
        ensureDirectoryExists()
    }

    private func ensureDirectoryExists() {
        [documentsURL, supportURL].forEach {
            if !fm.fileExists(atPath: $0.path) {
                try? fm.createDirectory(at: $0, withIntermediateDirectories: true)
            }
        }
    }

    func save<T: Encodable>(_ object: T, fileName: String, subdirectory: String? = nil) throws {
        let url = url(for: fileName, subdirectory: subdirectory)
        do {
            let data = try encoder.encode(object)
            try data.write(to: url, options: .atomic)
        } catch let error as EncodingError {
            throw FileManagerError.encodingFailed(error)
        } catch {
            throw FileManagerError.writeFailed(error)
        }
    }

    func load<T: Decodable>(_ type: T.Type, fileName: String, subdirectory: String? = nil) throws -> T {
        let url = url(for: fileName, subdirectory: subdirectory)
        guard fm.fileExists(atPath: url.path) else {
            throw FileManagerError.fileNotFound(fileName)
        }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(type, from: data)
        } catch let error as DecodingError {
            throw FileManagerError.decodingFailed(error)
        } catch {
            throw FileManagerError.readFailed(error)
        }
    }

    func delete(fileName: String, subdirectory: String? = nil) throws {
        let url = url(for: fileName, subdirectory: subdirectory)
        if fm.fileExists(atPath: url.path) {
            try fm.removeItem(at: url)
        }
    }

    func exists(fileName: String, subdirectory: String? = nil) -> Bool {
        fm.fileExists(atPath: url(for: fileName, subdirectory: subdirectory).path)
    }

    func listFiles(extension ext: String = "json", subdirectory: String? = nil) -> [String] {
        let dir = subdirectory.flatMap { documentsURL.appendingPathComponent($0) } ?? documentsURL
        guard let files = try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else { return [] }
        return files
            .filter { $0.pathExtension == ext }
            .map { $0.deletingPathExtension().lastPathComponent }
    }

    func saveUserProfile(_ profile: UserProfile) throws {
        try save(profile, fileName: "user_profile", subdirectory: "profiles")
    }

    func loadUserProfile() throws -> UserProfile {
        try load(UserProfile.self, fileName: "user_profile", subdirectory: "profiles")
    }

    private func url(for fileName: String, subdirectory: String?) -> URL {
        var base = documentsURL
        if let sub = subdirectory {
            base = base.appendingPathComponent(sub)
            if !fm.fileExists(atPath: base.path) {
                try? fm.createDirectory(at: base, withIntermediateDirectories: true)
            }
        }
        return base.appendingPathComponent("\(fileName).json")
    }
}
