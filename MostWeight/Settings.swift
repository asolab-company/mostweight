import SwiftUI

struct Settings: View {
    var onBack: () -> Void = {}
    @Environment(\.openURL) private var openURL
    @State private var showShare = false

    @AppStorage(unitSystemKey) private var unitRaw: String = UnitSystem.metric
        .rawValue
    private var unit: UnitSystem { UnitSystem(rawValue: unitRaw) ?? .metric }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 10) {

                HStack {
                    Button(action: { onBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Settings")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.left")
                        .opacity(0)
                }
                .padding(.horizontal, 30)
                .padding(.top, 8)
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "023F78"), Color(hex: "023F78"),
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .ignoresSafeArea()
                )

                SettingsRow(
                    title: "Terms and Conditions",
                    systemImage: "app_ic_settings"
                ) {
                    openURL(Links.terms)
                }
                .padding(.horizontal)

                SettingsRow(
                    title: "Privacy",
                    systemImage: "app_ic_settingss"
                ) {
                    openURL(Links.policy)
                }
                .padding(.horizontal)

                SettingsRow(
                    title: "Share app",
                    systemImage: "app_ic_settingsss"
                ) {
                    showShare = true
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Choose your preferred unit")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .regular))

                    UnitPreferenceCard(
                        selection: Binding<UnitSystem>(
                            get: { UnitSystem(rawValue: unitRaw) ?? .metric },
                            set: { unitRaw = $0.rawValue }
                        )
                    )

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                Spacer()
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "022347"), Color(hex: "094F98"),
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showShare) {
            ShareSheet(items: Links.shareItems)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct OptionRow: View {
    let title: String
    let unitLabel: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .regular))

                Spacer()

                Text(unitLabel)
                    .foregroundColor(Color(hex: "67A5E0"))
                    .font(.system(size: 14, weight: .regular))

                RadioDot(isOn: isSelected)
                    .padding(.leading, 12)
            }
            .padding(.horizontal, 20)
            .frame(height: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct RadioDot: View {
    let isOn: Bool
    var body: some View {
        ZStack {
            Circle()
                .fill(isOn ? Color(hex: "F85200") : Color.white)
            if isOn {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 24, height: 24)
        .overlay(
            Circle().stroke(Color.white, lineWidth: 2)
        )
        .shadow(radius: isOn ? 4 : 0, y: isOn ? 1 : 0)
        .animation(.easeOut(duration: 0.15), value: isOn)
    }
}

private struct UnitPreferenceCard: View {
    @Binding var selection: UnitSystem

    var body: some View {
        VStack(spacing: 0) {
            OptionRow(
                title: UnitSystem.metric.title,
                unitLabel: UnitSystem.metric.unitLabel,
                isSelected: selection == .metric
            ) {
                selection = .metric

            }

            Divider().overlay(Color(hex: "67A5E0"))

            OptionRow(
                title: UnitSystem.imperial.title,
                unitLabel: UnitSystem.imperial.unitLabel,
                isSelected: selection == .imperial
            ) {
                selection = .imperial
            }
        }
        .background(Color(hex: "002C59"))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
}

struct SettingsRow: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Image(systemImage)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(width: 40, height: 40)

                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .regular))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 10)
            }
            .padding(.horizontal, 16)
            .frame(height: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 100, style: .continuous)
                .fill(Color(hex: "002C59"))
        )
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }
    func updateUIViewController(
        _ vc: UIActivityViewController,
        context: Context
    ) {}
}

#Preview {
    Settings()
}
