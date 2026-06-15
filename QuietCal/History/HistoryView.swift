import SwiftUI

struct HistoryView: View {
    let viewModel: HistoryViewModel

    @State private var rendered = false

    private static let warnColor: Color = .orange
    private static let chartHeight: CGFloat = 130

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                weekCard
                earlierSection
            }
            .padding(.top, 4)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("History")
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
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(viewModel.week) { dayTotal in
                    weekBar(for: dayTotal)
                }
            }
            .frame(height: Self.chartHeight * 1.1)

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

    private func weekBar(for dayTotal: DayTotal) -> some View {
        let isOver = dayTotal.kcal > viewModel.target
        let pct = min(Double(dayTotal.kcal) / Double(max(viewModel.target, 1)), 1.1)
        let barColor: Color = isOver ? Self.warnColor : .primary
        let barHeight = Self.chartHeight * pct

        return VStack(spacing: 6) {
            ZStack(alignment: .bottom) {
                Color.clear
                    .frame(height: Self.chartHeight * 1.1)

                RoundedRectangle(cornerRadius: 6)
                    .fill(barColor)
                    .opacity(dayTotal.isToday ? 1.0 : 0.85)
                    .frame(height: rendered ? max(barHeight, 2) : 0)
                    .overlay(alignment: .top) {
                        if dayTotal.isToday && dayTotal.kcal > 0 {
                            Text(dayTotal.kcal.formatted())
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.primary)
                                .offset(y: -16)
                                .opacity(rendered ? 1 : 0)
                        }
                    }
            }

            Text(dayTotal.weekdayLetter)
                .font(.system(size: 12, weight: dayTotal.isToday ? .bold : .medium))
                .foregroundStyle(dayTotal.isToday ? Color.primary : Color.secondary)
        }
        .frame(maxWidth: .infinity)
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
