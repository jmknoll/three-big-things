import SwiftUI

struct OnboardingNotificationsView: View {
    let onContinue: () -> Void

    @State private var morningTime: Date = {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = 8; c.minute = 0
        return Calendar.current.date(from: c) ?? Date()
    }()
    @State private var eveningTime: Date = {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = 20; c.minute = 0
        return Calendar.current.date(from: c) ?? Date()
    }()

    var body: some View {
        ZStack {
            Color.canvas.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Space.xl3) {
                Spacer()

                VStack(alignment: .leading, spacing: Space.sm) {
                    Text("Evensong works best\nwith daily reminders.")
                        .font(.title.bold())
                        .foregroundStyle(Color.ink)
                }
                .padding(.horizontal, Space.xl)

                VStack(spacing: Space.md) {
                    timeRow(label: "Morning reminder", time: $morningTime)
                    timeRow(label: "Evening check-in", time: $eveningTime)
                }
                .padding(.horizontal, Space.xl)

                Spacer()

                VStack(spacing: Space.md) {
                    CTAButton(title: "Enable reminders", isEnabled: true) {
                        let granted = await NotificationManager.shared.requestPermission()
                        if granted {
                            await NotificationManager.shared.scheduleAll(
                                morningTime: morningTime.toHHMM(),
                                eodTime: eveningTime.toHHMM()
                            )
                        }
                        onContinue()
                    }
                    .padding(.horizontal, Space.xl)

                    Button("Not now") { onContinue() }
                        .font(.subheadline)
                        .foregroundStyle(Color.stone)
                }
                .padding(.bottom, Space.xl2)
            }
        }
    }

    @ViewBuilder
    private func timeRow(label: String, time: Binding<Date>) -> some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(Color.ink)
            Spacer()
            DatePicker("", selection: time, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .padding(Space.md)
        .background(Color.surface)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.mist, lineWidth: 1))
    }
}

private extension Date {
    func toHHMM() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: self)
    }
}

