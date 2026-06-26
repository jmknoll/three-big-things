import SwiftUI

struct CTAButton: View {
    let title: String
    let isEnabled: Bool
    let action: () async -> Void

    @State private var isPressed = false
    @State private var isRunning = false

    var body: some View {
        Button {
            guard isEnabled && !isRunning else { return }
            isRunning = true
            HapticManager.light()
            Task {
                await action()
                isRunning = false
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isEnabled ? Color.sage : Color.fog)
                Text(isRunning ? "..." : title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.vertical, Space.md)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .disabled(!isEnabled || isRunning)
    }
}
