import SwiftUI

struct AddWeight: View {
    var onBack: () -> Void = {}
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @State private var showShare = false

    @State private var selection: UnitSystem = .metric
    @State private var weight: String = ""
    @FocusState private var isWeightFocused: Bool
    private let weightValueKey = "lastWeightValue"
    private let weightDateKey = "lastWeightDate"

    private var parsedWeight: Double? {
        Double(weight.replacingOccurrences(of: ",", with: "."))
    }
    private var isWeightValid: Bool {
        if let v = parsedWeight { return v >= 5 && v <= 200 }
        return false
    }

    var body: some View {

        ZStack(alignment: .top) {

            VStack(spacing: 30) {
                HStack {
                    Button(action: { onBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button {
                        weight = ""
                        isWeightFocused = false
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "F85200"))
                    }
                }
                .overlay(
                    Text("Add new weight")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )

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

                Image("app_ic_mainweight")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .padding(.top)

                Text("Enter your weight")
                    .foregroundColor(.white)
                    .textCase(.uppercase)
                    .font(.system(size: 24, weight: .black))

                TextField("Enter your weight", text: $weight)
                    .padding(.horizontal, 20)
                    .frame(height: 54)
                    .background(Color.white)
                    .keyboardType(.decimalPad)
                    .focused($isWeightFocused)
                    .submitLabel(.done)
                    .cornerRadius(27)
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .regular))
                    .placeholder(when: weight.isEmpty) {
                        Text("Enter your weight")
                            .foregroundColor(Color(hex: "67A5E0"))
                            .font(.system(size: 16, weight: .regular))
                    }
                    .padding(.horizontal)
                    .onAppear {

                        isWeightFocused = true
                    }

                if !weight.isEmpty && !isWeightValid {
                    Text("Allowed range: 5–200")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {

                    if let value = parsedWeight, value >= 5 && value <= 200 {
                        var allRecords: [DayWeight] = []
                        if let data = UserDefaults.standard.data(
                            forKey: "weightRecords"
                        ),
                            let decoded = try? JSONDecoder().decode(
                                [DayWeight].self,
                                from: data
                            )
                        {
                            allRecords = decoded
                        }
                        allRecords.append(DayWeight(date: Date(), value: value))
                        if let encoded = try? JSONEncoder().encode(allRecords) {
                            UserDefaults.standard.set(
                                encoded,
                                forKey: "weightRecords"
                            )
                        }

                        UserDefaults.standard.set(value, forKey: weightValueKey)
                        UserDefaults.standard.set(Date(), forKey: weightDateKey)

                        isWeightFocused = false
                        onBack()
                    }
                } label: {
                    ZStack {
                        Text("Save")
                            .font(.system(size: 16, weight: .bold))
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)

                }
                .buttonStyle(BtnStyle())

                .disabled(!isWeightValid)
                .opacity(isWeightValid ? 1.0 : 0.6)
                .padding(.bottom, 8)
                .padding(.horizontal)

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

    }

}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow { placeholder() }
            self
        }
    }
}

#Preview {
    AddWeight()
}
