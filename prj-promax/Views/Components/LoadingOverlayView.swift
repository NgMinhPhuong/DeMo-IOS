import SwiftUI

struct LoadingOverlayView: View {
    let isLoading: Bool
    let message: String

    var body: some View {
        if isLoading {
            ZStack {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.3)
                    Text(message)
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
            }
            .transition(.opacity.animation(.easeInOut(duration: 0.2)))
        }
    }
}

#Preview {
    LoadingOverlayView(isLoading: true, message: "Loading...")
}
