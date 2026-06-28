import SwiftUI
import Charts

struct HistoryView: View {
    let viewModel: HistoryViewModel

    @State private var rendered = false
    @State private var showPaywall = false

    private static let warnColor: Color = .orange
    private static let chartHeight: CGFloat = 130

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                weekCard
                if viewModel.historyLocked {
                    lockedEarlierCard
                } else {
                    earlierSection
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("History")
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .task {
            await viewModel.load()
            withAnimation(.easeOut(duration: 0.7).delay(0.1)) {
                rendered = true
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        Text("AVERAGE · \(viewModel.averageKcal.formatted()) KCAL")
            .font(.system(size: 13, weight: .medium))
            .tracking(0.5)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
    }

    // MARK: - Week chart

    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            chart

            HStack {
                Text("THIS WEEK")
                Spacer()
                Text("TARGET \(viewModel.target.formatted())")
            }
            .font(.system(size: 11, weight: .medium))
            .tracking(0.5)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
        .padding(.horizontal, 18)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22))
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private var chart: some View {
        let target = viewModel.target
        let maxY = Double(max(target, 1)) * 1.1

        return Chart {
            ForEach(viewModel.week) { dayTotal in
                let cappedKcal = min(Double(dayTotal.kcal), maxY)

                BarMark(
                    x: .value("Day", dayTotal.date, unit: .day),
                    y: .value("Kcal", rendered ? cappedKcal : 0),
                    width: .ratio(0.7)
                )
                .foregroundStyle(dayTotal.kcal > target ? Self.warnColor : Color.primary)
                .opacity(dayTotal.isToday ? 1.0 : 0.85)
                .cornerRadius(6)
                .annotation(position: .top, spacing: 4) {
                    if dayTotal.isToday && dayTotal.kcal > 0 {
                        Text(dayTotal.kcal.formatted())
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                            .opacity(rendered ? 1 : 0)
                    }
                }
            }

            RuleMark(y: .value("Target", target))
                .foregroundStyle(Color.secondary.opacity(0.4))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
        .chartYScale(domain: 0...maxY)
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: viewModel.week.map(\.date)) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        let isToday = Calendar.current.isDateInToday(date)
                        Text(date.formatted(.dateTime.weekday(.narrow)))
                            .font(.system(size: 12, weight: isToday ? .bold : .medium))
                            .foregroundStyle(isToday ? Color.primary : Color.secondary)
                    }
                }
            }
        }
        .frame(height: Self.chartHeight * 1.1)
    }

    // MARK: - Locked earlier (free tier)

    private var lockedEarlierCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EARLIER")
                .font(.system(size: 13, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            Button {
                showPaywall = true
            } label: {
                VStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)

                    Text("See your full history")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text("Free shows the last \(FreeTierLimits.freeHistoryDays) days. Unlock every day you've tracked with QuietCal Pro.")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Unlock with Pro")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(.systemBackground))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 11)
                        .background(Color.primary, in: Capsule())
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .padding(.horizontal, 20)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Earlier list

    private var earlierSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EARLIER")
                .font(.system(size: 13, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            if viewModel.earlier.isEmpty {
                Text("No earlier history yet.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.earlier.enumerated()), id: \.element.id) { index, dayTotal in
                        earlierRow(dayTotal, isLast: index == viewModel.earlier.count - 1)
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 18)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22))
            }
        }
        .padding(.horizontal, 20)
    }

    private func earlierRow(_ dayTotal: DayTotal, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayTotal.weekdayName)
                        .font(.system(size: 17, weight: .medium))
                        .tracking(-0.4)
                        .foregroundStyle(.primary)
                    Text(dayTotal.shortDate)
                        .font(.system(size: 13))
                        .tracking(-0.08)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(dayTotal.kcal.formatted())
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .tracking(-0.4)
                    .monospacedDigit()
                    .foregroundStyle(dayTotal.kcal > viewModel.target ? Self.warnColor : Color.primary)
            }
            .padding(.vertical, 14)

            if !isLast {
                Rectangle()
                    .fill(Color.primary.opacity(0.12))
                    .frame(height: 0.5)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView(viewModel: HistoryViewModel(
            mealStore: InMemoryMealStore(meals: .historySample),
            settingsStore: InMemorySettingsStore()
        ))
    }
}

#Preview("Empty") {
    NavigationStack {
        HistoryView(viewModel: HistoryViewModel(
            mealStore: InMemoryMealStore(meals: .empty),
            settingsStore: InMemorySettingsStore()
        ))
    }
}
