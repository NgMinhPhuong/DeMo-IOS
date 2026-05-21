import SwiftUI

struct InfoRowView: View {
    let label: String
    let value: String
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
            }
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    List {
        InfoRowView(label: "Name", value: "John", icon: "person")
        InfoRowView(label: "Email", value: "john@example.com", icon: "envelope")
    }
}
