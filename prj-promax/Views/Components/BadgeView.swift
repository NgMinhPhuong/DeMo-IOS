import SwiftUI

enum BadgeStyle {
    case success, warning, danger, info

    var color: Color {
        switch self {
        case .success: return .green
        case .warning: return .orange
        case .danger:  return .red
        case .info:    return .blue
        }
    }
}

struct BadgeView: View {
    let text: String
    let style: BadgeStyle

    var body: some View {
        Text(text)
            .font(.caption2).bold()
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(style.color)
            .cornerRadius(6)
    }
}

#Preview {
    HStack {
        BadgeView(text: "Active", style: .success)
        BadgeView(text: "Pending", style: .warning)
        BadgeView(text: "Blocked", style: .danger)
        BadgeView(text: "Info", style: .info)
    }
}
