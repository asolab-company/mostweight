import SwiftUI

private let onboardingShownKey = "onboardingShown"

enum AppRoute {
    case loading
    case onboarding
    case main
    case settings
    case addWeight
}

struct RootView: View {
    @State private var route: AppRoute = .loading

    var body: some View {
        ZStack {
            switch route {
            case .loading:
                Loading {
                    withAnimation(.easeInOut) {
                        let needsOnboarding = !UserDefaults.standard.bool(
                            forKey: onboardingShownKey
                        )
                        route = needsOnboarding ? .onboarding : .main
                    }
                }
                .transition(.opacity)

            case .onboarding:
                Onboarding {
                    UserDefaults.standard.set(true, forKey: onboardingShownKey)
                    withAnimation(.easeInOut) {
                        route = .main
                    }
                }
                .transition(.move(edge: .trailing))

            case .main:
                Main(onContinue: {
                    withAnimation(.easeInOut) { route = .addWeight }
                })
                .overlay(alignment: .topTrailing) {
                    Button {
                        withAnimation(.easeInOut) { route = .settings }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color(hex: "F85200"))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                }
                .transition(.opacity)

            case .settings:
                Settings(onBack: {
                    withAnimation(.easeInOut) { route = .main }
                })
                .transition(.move(edge: .trailing))

            case .addWeight:
                AddWeight(onBack: {
                    withAnimation(.easeInOut) { route = .main }
                })
                .transition(.move(edge: .bottom))
            }
        }
    }
}

#Preview {
    RootView()
}
