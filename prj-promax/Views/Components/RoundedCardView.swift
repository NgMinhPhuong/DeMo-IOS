import SwiftUI

struct RoundedCardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    RoundedCardView {
        VStack(alignment: .leading, spacing: 8) {
            Text("Card Title").font(.headline)
            Text("Card content goes here").foregroundColor(.secondary)
        }
    }
    .padding()
}
