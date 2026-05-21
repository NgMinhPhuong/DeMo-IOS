import SwiftUI

struct PriceText: View {
    let price: Double
    var font: Font = .body
    var color: Color = .blue

    var body: some View {
        Text("$\(price, specifier: "%.2f")")
            .font(font).bold()
            .foregroundColor(color)
    }
}

#Preview {
    VStack {
        PriceText(price: 29.99, font: .title, color: .blue)
        PriceText(price: 9.99, font: .body, color: .green)
    }
}
