import SwiftUI

struct ProfileAvatarView: View {
    let name: String
    let url: String?
    var size: CGFloat = 60

    var body: some View {
        if let url, let imageURL = URL(string: url) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                default:
                    InitialsAvatar(name: name, size: size)
                }
            }
        } else {
            InitialsAvatar(name: name, size: size)
        }
    }
}

private struct InitialsAvatar: View {
    let name: String
    let size: CGFloat

    var initials: String {
        name.split(separator: " ").compactMap { $0.first }.map(String.init).joined().uppercased()
    }

    var body: some View {
        Text(initials.isEmpty ? "?" : String(initials.prefix(2)))
            .font(.system(size: size * 0.4, weight: .bold))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(Circle().fill(Color.blue.gradient))
    }
}

#Preview {
    VStack(spacing: 16) {
        ProfileAvatarView(name: "John Doe", url: nil, size: 72)
        ProfileAvatarView(name: "Jane Smith", url: "https://i.pravatar.cc/150", size: 72)
    }
}
