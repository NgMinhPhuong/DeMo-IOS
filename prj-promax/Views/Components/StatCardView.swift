import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    var icon: String? = nil
    var color: Color = .blue

    var body: some View {
        VStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            Text(value)
                .font(.title).bold()
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    HStack {
        StatCardView(title: "Items", value: "42", icon: "list.number", color: .blue)
        StatCardView(title: "Price", value: "$99", icon: "dollarsign.circle", color: .green)
    }
    .padding()
}
