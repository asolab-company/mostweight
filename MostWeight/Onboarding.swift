import SwiftUI

struct Onboarding: View {
    var onContinue: () -> Void = {}

    @State private var selection: UnitSystem = .metric

    var body: some View {
        ZStack(alignment: .top) {

            GeometryReader { geo in
                VStack {
                    Spacer()

                    VStack(spacing: 5) {

                        Spacer()

                        Image("app_bg_welcome")
                            .resizable()
                            .scaledToFill()
                            .padding(.vertical)
                            .frame(height: Device.isSmall ? 120 : 240)

                        Text("Track your weight effortlessly.")
                            .foregroundColor(.white)
                            .font(.system(size: 32, weight: .heavy))
                            .padding(.bottom)
                            .textCase(.uppercase)
                            .padding(.horizontal)

                        Text(
                            "No goals, no pressure — just clear, simple data. Open the app, log your weight, and see your progress over time. Clean design. Instant updates. Pure tracking."
                        )
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .regular))
                        .padding(.bottom)
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Choose your preferred unit")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .regular))

                            UnitPreferenceCard(selection: $selection)

                        }.padding(.horizontal)
                            .padding(.bottom)

                        Button(action: {
                            UserDefaults.standard.set(
                                selection.rawValue,
                                forKey: unitSystemKey
                            )
                            onContinue()
                        }) {
                            ZStack {
                                Text("Continue")
                                    .font(.system(size: 16, weight: .bold))
                                HStack {
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(
                                            .system(size: 18, weight: .bold)
                                        )
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BtnStyle())
                        .padding(.bottom, 8)
                        .padding(.horizontal)

                        TermsFooter().padding(
                            .bottom,
                            Device.isSmall ? 20 : 60
                        )
                        .padding(.horizontal)

                    }

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.ignoresSafeArea()
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
    }
}

private struct TermsFooter: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("By Proceeding You Accept")
                .foregroundColor(Color.init(hex: "C5C5C5"))
                .font(.footnote)

            HStack(spacing: 0) {
                Text("Our ")
                    .foregroundColor(Color.init(hex: "C5C5C5"))
                    .font(.footnote)

                Link("Terms Of Use", destination: Links.terms)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "FFFFFF"))

                Text(" And ")
                    .foregroundColor(Color.init(hex: "C5C5C5"))
                    .font(.footnote)

                Link("Privacy Policy", destination: Links.policy)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "FFFFFF"))

            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

struct BtnStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#F95B01"), Color(hex: "#F84401"),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "#F95B01").opacity(0.8),
                                Color(hex: "#F84401").opacity(0.8),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .blur(radius: 2)
                    .opacity(configuration.isPressed ? 0.5 : 1)
            )
            .overlay(
                Capsule()
                    .stroke(
                        Color.white.opacity(
                            configuration.isPressed ? 0.25 : 0.12
                        ),
                        lineWidth: 1
                    )
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(
                color: Color(hex: "#F95B01").opacity(0.7),
                radius: configuration.isPressed ? 2 : 2,
                y: 2
            )
            .shadow(
                color: Color(hex: "#F84401").opacity(0.5),
                radius: configuration.isPressed ? 2 : 4,
                y: 0
            )
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
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
                    .foregroundColor(Color.init(hex: "67A5E0"))
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
                .fill(isOn ? Color.init(hex: "F85200") : Color.white)
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
            ) { selection = .metric }

            Divider()
                .overlay(Color.init(hex: "67A5E0"))

            OptionRow(
                title: UnitSystem.imperial.title,
                unitLabel: UnitSystem.imperial.unitLabel,
                isSelected: selection == .imperial
            ) { selection = .imperial }
        }
        .background(
            Color(hex: "08488B")

        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

    }
}

#Preview {
    Onboarding {
        print("Finished")
    }
}
