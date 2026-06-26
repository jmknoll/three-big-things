import SwiftUI

struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            Spacer()
            if isShowing {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(Color.surface)
                    .padding(.horizontal, Space.lg)
                    .padding(.vertical, Space.sm)
                    .background(Color.slate.opacity(0.95))
                    .cornerRadius(14)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            withAnimation { isShowing = false }
                        }
                    }
                    .padding(.bottom, Space.xl)
            }
        }
        .animation(.sheetRise, value: isShowing)
    }
}
