import SwiftUI

enum ButtonStyleKind {
    case primary, secondary, destructive
}

struct ActionButton: View {
    let title: String
    let systemImage: String?
    let style: ButtonStyleKind
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        style: ButtonStyleKind = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let image = systemImage {
                    Image(systemName: image)
                }
                Text(title)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(BorderedProminentButtonStyle())
        .tint(tintColor)
    }

    private var tintColor: Color {
        switch style {
        case .primary:     return .blue
        case .secondary:   return .gray
        case .destructive: return .red
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ActionButton("Primary", systemImage: "hand.thumbsup", style: .primary, action: {})
        ActionButton("Secondary", systemImage: "gearshape", style: .secondary, action: {})
        ActionButton("Delete", systemImage: "trash", style: .destructive, action: {})
    }
    .padding()
}
