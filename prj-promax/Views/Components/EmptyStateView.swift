import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: systemImage,
            description: Text(message)
        )
    }
}

#Preview {
    EmptyStateView(title: "No Items", message: "Your list is empty", systemImage: "tray")
}
