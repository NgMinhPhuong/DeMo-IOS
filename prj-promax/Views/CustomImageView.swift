import SwiftUI

struct CustomImageView: View {
    let url: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        if let imageURL = URL(string: url) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: width, height: height)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()
                case .failure:
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .frame(width: width, height: height)
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Image(systemName: "photo")
                .font(.largeTitle)
                .foregroundColor(.gray)
                .frame(width: width, height: height)
        }
    }
}

#Preview {
    CustomImageView(url: "https://picsum.photos/400/200", width: 300, height: 200)
}
