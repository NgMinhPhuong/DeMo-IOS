import SwiftUI

struct SectionHeaderView: View {
    let title: String
    var count: Int? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.title3).bold()
            if let count {
                Text("(\(count))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    VStack {
        SectionHeaderView(title: "Profile", count: nil)
        SectionHeaderView(title: "Items", count: 5)
    }
    .padding()
}
