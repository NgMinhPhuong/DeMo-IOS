import UIKit

enum LocalImageError: LocalizedError {
    case saveFailed
    case loadFailed
    case invalidImageData

    var errorDescription: String? {
        switch self {
        case .saveFailed: return "Failed to save image"
        case .loadFailed: return "Failed to load image"
        case .invalidImageData: return "Invalid image data"
        }
    }
}

final class LocalImageService {
    static let shared = LocalImageService()

    private let fm = FileManager.default

    private var imagesDir: URL {
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("images", isDirectory: true)
    }

    private init() {
        if !fm.fileExists(atPath: imagesDir.path) {
            try? fm.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }
    }

    func save(image: UIImage) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw LocalImageError.invalidImageData
        }
        let filename = "\(UUID().uuidString).jpg"
        let url = imagesDir.appendingPathComponent(filename)
        try data.write(to: url)
        return filename
    }

    func load(filename: String) -> UIImage? {
        let url = imagesDir.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func delete(filename: String) {
        let url = imagesDir.appendingPathComponent(filename)
        try? fm.removeItem(at: url)
    }
}
