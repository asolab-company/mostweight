import Charts
import SwiftUI

enum Period: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case total = "Total"
    var id: String { rawValue }
}

struct DayWeight: Identifiable, Codable {
    let id: UUID
    let date: Date
    let value: Double

    init(id: UUID = UUID(), date: Date, value: Double) {
        self.id = id
        self.date = date
        self.value = value
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let p = pow(10.0, Double(places))
        return (self * p).rounded() / p
    }
}

struct Main: View {
    var onContinue: () -> Void = {}
    @State private var period: Period = .week

    @AppStorage(unitSystemKey) private var unitRaw: String = UnitSystem.metric
        .rawValue
    private var unit: UnitSystem { UnitSystem(rawValue: unitRaw) ?? .metric }

    @State private var windowStart: Date = Calendar.current.startOfDay(
        for: Date()
    )
    @State private var data: [DayWeight] = []

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { _ in
                VStack(spacing: 5) {
                    Image("app_ic_mainweight")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .padding(.top, Device.isSmall ? 20 : 50)

                    Text("Track your weight effortlessly.")
                        .foregroundColor(.white)
                        .font(
                            .system(
                                size: Device.isSmall ? 26 : 32,
                                weight: .heavy
                            )
                        )
                        .textCase(.uppercase)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)

                    Text("No goals, no pressure — just clear, simple data.")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .regular))
                        .padding(.bottom)
                        .padding(.horizontal)

                    PeriodSegmentedControl(selection: $period)
                        .padding(.horizontal, 16)

                    VStack(spacing: 16) {
                        header
                        chart

                        HStack(spacing: 20) {
                            StatCard(
                                value: minValueDisplay,
                                unitLabel: unit.unitLabel,
                                label: "Min weight"
                            )
                            StatCard(
                                value: maxValueDisplay,
                                unitLabel: unit.unitLabel,
                                label: "Max weight"
                            )
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)

                    Spacer()

                    Button(action: { onContinue() }) {
                        ZStack {
                            Text("Add new weight")
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
                    .padding(.top)
                    .padding(.horizontal)
                    .padding(.bottom)

                    Spacer()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea()
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
        .onAppear {
            if let savedData = UserDefaults.standard.data(
                forKey: "weightRecords"
            ),
                let decoded = try? JSONDecoder().decode(
                    [DayWeight].self,
                    from: savedData
                )
            {
                data = decoded.sorted(by: { $0.date < $1.date })
            } else {
                data = []
            }
            windowStart = initialWindowStart(for: period, data: data)
        }
        .onChange(of: period) { newValue in
            windowStart = initialWindowStart(for: newValue, data: data)
        }
    }

    private var header: some View {
        HStack {
            Button {
                shiftWindow(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .opacity(period == .total ? 0.3 : 1)
            .disabled(period == .total)

            Spacer()
            Text(periodTitle)
                .font(.system(size: 16, weight: .black))
                .foregroundColor(.white)
            Spacer()

            Button {
                shiftWindow(by: +1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .opacity(period == .total ? 0.3 : 1)
            .disabled(period == .total)
        }
        .padding(.horizontal, 16)
    }

    private var filteredData: [DayWeight] {
        data.filter { $0.date >= windowStart && $0.date <= windowEnd }
    }

    private var windowEnd: Date {
        let cal = Calendar.current
        switch period {
        case .week:
            return cal.date(byAdding: .day, value: 6, to: windowStart)
                ?? windowStart
        case .month:
            let startOfMonth =
                cal.date(
                    from: cal.dateComponents(
                        [.year, .month],
                        from: windowStart
                    )
                ) ?? windowStart
            let nextMonth =
                cal.date(byAdding: .month, value: 1, to: startOfMonth)
                ?? startOfMonth
            return cal.date(byAdding: .day, value: -1, to: nextMonth)
                ?? startOfMonth
        case .year:
            return cal.date(byAdding: .year, value: 1, to: windowStart)
                ?? windowStart
        case .total:
            return data.last?.date ?? windowStart
        }
    }

    private var domainX: ClosedRange<Date> {
        let start = windowStart
        let end = windowEnd
        if Calendar.current.isDate(start, inSameDayAs: end) {
            let pad: TimeInterval = 60 * 60 * 24
            return start...(Date(timeInterval: pad, since: end))
        }
        return start...end
    }

    private func initialWindowStart(for period: Period, data: [DayWeight])
        -> Date
    {
        let cal = Calendar.current
        switch period {
        case .week:
            let ref = data.last?.date ?? Date()
            return startOfWeek(for: ref)
        case .month:
            let ref = data.last?.date ?? Date()
            return cal.date(
                from: cal.dateComponents([.year, .month], from: ref)
            ) ?? ref
        case .year:
            let ref = data.last?.date ?? Date()
            return cal.date(from: cal.dateComponents([.year], from: ref)) ?? ref
        case .total:
            return data.first?.date ?? Date()
        }
    }

    private func startOfWeek(for date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents(
            [.yearForWeekOfYear, .weekOfYear],
            from: date
        )
        return cal.date(from: comps) ?? date
    }

    private func shiftWindow(by delta: Int) {
        let cal = Calendar.current
        switch period {
        case .week:
            if let d = cal.date(
                byAdding: .day,
                value: 7 * delta,
                to: windowStart
            ) {
                windowStart = d
            }
        case .month:
            if let d = cal.date(byAdding: .month, value: delta, to: windowStart)
            {
                windowStart =
                    cal.date(
                        from: cal.dateComponents([.year, .month], from: d)
                    ) ?? d
            }
        case .year:
            if let d = cal.date(byAdding: .year, value: delta, to: windowStart)
            {
                windowStart =
                    cal.date(from: cal.dateComponents([.year], from: d)) ?? d
            }
        case .total:
            break
        }
    }

    private var periodTitle: AttributedString {
        let formatter = DateFormatter()
        formatter.locale = .current
        switch period {
        case .week:
            formatter.setLocalizedDateFormatFromTemplate("d MMM")
            return AttributedString(
                "\(formatter.string(from: windowStart)) — \(formatter.string(from: windowEnd))"
            )
        case .month:
            formatter.setLocalizedDateFormatFromTemplate("LLLL yyyy")
            return AttributedString(formatter.string(from: windowStart))
        case .year:
            formatter.setLocalizedDateFormatFromTemplate("yyyy")
            return AttributedString(formatter.string(from: windowStart))
        case .total:
            return AttributedString("All time")
        }
    }

    private func bucketKey(for date: Date) -> Date {
        let cal = Calendar.current
        switch period {
        case .week, .month:
            return cal.startOfDay(for: date)
        case .year, .total:
            let comps = cal.dateComponents([.year, .month], from: date)
            return cal.date(from: comps) ?? cal.startOfDay(for: date)
        }
    }

    private var binnedData: [DayWeight] {
        let grouped = Dictionary(
            grouping: filteredData,
            by: { bucketKey(for: $0.date) }
        )
        let averaged: [DayWeight] = grouped.map { (key, arr) in
            let avgKg = arr.reduce(0.0) { $0 + $1.value } / Double(arr.count)
            return DayWeight(date: key, value: avgKg.rounded(toPlaces: 1))
        }
        return averaged.sorted { $0.date < $1.date }
    }

    private var chart: some View {

        let plottedDisplay: [DayWeight] = binnedData.map {
            DayWeight(
                date: $0.date,
                value: unit.toDisplay(fromKilograms: $0.value)
            )
        }

        let maxY = (plottedDisplay.map(\.value).max() ?? 0).rounded(.up)
        let chartHeight: CGFloat = Device.isSmall ? 160 : 300

        return VStack(spacing: 0) {
            if plottedDisplay.isEmpty {
                Text("No data yet")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 16, weight: .medium))
                    .frame(height: chartHeight)
            } else {
                Chart {
                    ForEach(plottedDisplay) { point in
                        RuleMark(
                            x: .value("Bucket", point.date),
                            yStart: .value("Min", 0),
                            yEnd: .value("Weight", point.value)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        .foregroundStyle(Color(hex: "F85200"))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: xAxisTickDates()) { _ in
                        AxisGridLine().foregroundStyle(
                            Color.white.opacity(0.20)
                        )
                        AxisTick().foregroundStyle(Color.white.opacity(0.35))
                        AxisValueLabel().foregroundStyle(.clear)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine().foregroundStyle(
                            Color.white.opacity(0.15)
                        )
                        AxisTick().foregroundStyle(Color.white.opacity(0.6))
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text("\(v, specifier: "%.0f")")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 12, weight: .regular))
                            }
                        }
                    }
                }
                .chartYScale(domain: 0...(maxY > 0 ? maxY : 110))
                .chartXScale(domain: domainX)
                .animation(.easeInOut(duration: 0.25), value: period)
                .frame(height: chartHeight)
                .padding(.horizontal, 20)
            }
        }
    }

    private func xAxisTickDates() -> [Date] {
        let cal = Calendar.current
        switch period {
        case .week:
            return (0...6).compactMap {
                cal.date(byAdding: .day, value: $0, to: windowStart)
            }

        case .month:
            var dates: [Date] = []
            var cursor = startOfWeek(for: windowStart)
            while cursor <= windowEnd {
                dates.append(cursor)
                cursor =
                    cal.date(byAdding: .day, value: 7, to: cursor) ?? cursor
                if dates.count > 10 { break }
            }
            if let last = dates.last, last != windowEnd {
                dates.append(windowEnd)
            }
            return dates

        case .year:
            var dates: [Date] = []
            var comps = cal.dateComponents([.year, .month], from: windowStart)
            comps.day = 1
            var cursor = cal.date(from: comps) ?? windowStart
            while cursor <= windowEnd {
                dates.append(cursor)
                cursor =
                    cal.date(byAdding: .month, value: 1, to: cursor) ?? cursor
                if dates.count > 13 { break }
            }
            if let last = dates.last, last != windowEnd {
                dates.append(windowEnd)
            }
            return dates

        case .total:
            let span = windowEnd.timeIntervalSince(windowStart)
            let eighteenMonths: TimeInterval = 60 * 60 * 24 * 30 * 18
            if span > eighteenMonths {
                var dates: [Date] = []
                var y = cal.component(.year, from: windowStart)
                let lastY = cal.component(.year, from: windowEnd)
                while y <= lastY {
                    if let d = cal.date(
                        from: DateComponents(year: y, month: 1, day: 1)
                    ) {
                        dates.append(d)
                    }
                    y += 1
                    if dates.count > 20 { break }
                }
                if let last = dates.last, last != windowEnd {
                    dates.append(windowEnd)
                }
                return dates
            } else {
                var dates: [Date] = []
                var comps = cal.dateComponents(
                    [.year, .month],
                    from: windowStart
                )
                comps.day = 1
                var cursor = cal.date(from: comps) ?? windowStart
                while cursor <= windowEnd {
                    dates.append(cursor)
                    cursor =
                        cal.date(byAdding: .month, value: 1, to: cursor)
                        ?? cursor
                    if dates.count > 24 { break }
                }
                if let last = dates.last, last != windowEnd {
                    dates.append(windowEnd)
                }
                return dates
            }
        }
    }

    private var minValueDisplay: Double {
        guard let minKg = filteredData.map(\.value).min() else { return 0 }
        return unit.toDisplay(fromKilograms: minKg)
    }

    private var maxValueDisplay: Double {
        guard let maxKg = filteredData.map(\.value).max() else { return 0 }
        return unit.toDisplay(fromKilograms: maxKg)
    }
}

extension Main {
    static func mockMonth(shift: Int = 0, base: Date = Date()) -> [DayWeight] {
        let cal = Calendar.current
        let baseMonth =
            cal.date(byAdding: .month, value: shift, to: base) ?? base
        let startOfMonth = cal.date(
            from: cal.dateComponents([.year, .month], from: baseMonth)
        )!
        let range =
            cal.range(of: .day, in: .month, for: startOfMonth) ?? (1..<31)
        let baseWeight: Double = 107.0
        return range.compactMap { day -> DayWeight in
            let date = cal.date(
                byAdding: .day,
                value: day - 1,
                to: startOfMonth
            )!
            let noise = Double.random(in: -2.0...2.2)
            return DayWeight(
                date: date,
                value: (baseWeight + noise).rounded(toPlaces: 1)
            )
        }
    }
}

private struct StatCard: View {
    let value: Double
    let unitLabel: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(value, specifier: "%.1f") \(unitLabel)")
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(.white)
            HStack(spacing: 8) {
                Image("app_ic_scale")
                Text(label)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.init(hex: "67A5E0"))
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(hex: "08488B"))
        )
    }
}

struct PeriodSegmentedControl: View {
    @Binding var selection: Period
    private let height: CGFloat = 40
    private let corner: CGFloat = 20

    var body: some View {
        GeometryReader { geo in
            let inset: CGFloat = 4
            let w =
                (geo.size.width - inset * 2) / CGFloat(Period.allCases.count)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(Color.white.opacity(0.18))

                Capsule()
                    .fill(Color.white)
                    .frame(width: w - 2, height: height - inset * 2)
                    .padding(.vertical, inset)
                    .padding(.horizontal, inset)
                    .offset(x: w * CGFloat(index(of: selection)) + 1, y: 0)
                    .animation(
                        .spring(response: 0.28, dampingFraction: 0.9),
                        value: selection
                    )

                HStack(spacing: 0) {
                    ForEach(Period.allCases) { p in
                        Button {
                            selection = p
                        } label: {
                            Text(p.rawValue)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                                .contentShape(Rectangle())
                                .foregroundColor(
                                    p == selection
                                        ? Color(hex: "F85200")
                                        : Color.white.opacity(0.65)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, inset)
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func index(of p: Period) -> Int {
        Period.allCases.firstIndex(of: p) ?? 0
    }
}

#Preview {
    Main {
        print("Finished")
    }
}
