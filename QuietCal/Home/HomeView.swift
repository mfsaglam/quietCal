import SwiftUI

// MARK: - Home View

struct HomeView: View {
    var viewModel: HomeViewModel

    @State private var ringAnimated = false
    @State private var showAddMeal = false
    @State private var showSettings = false
    @State private var settingsViewModel: SettingsViewModel?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ringSection
                        statStrip
                        mealsSection
                    }
                }
                .scrollIndicators(.hidden)

                fab
            }
            .navigationTitle("Today")
            .navigationSubtitle(viewModel.dateLabel)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {

                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 14))
                            Text("History")
                                .font(.system(size: 15, weight: .medium))
                        }
                    }
                }

                ToolbarSpacer(.fixed, placement: .primaryAction)

                ToolbarItem(placement: .primaryAction) {
                    Button("Settings", systemImage: "gearshape") {
                        settingsViewModel = viewModel.makeSettingsViewModel()
                        showSettings = true
                    }
                }
            }
            .task {
                await viewModel.load()
                withAnimation(.easeOut(duration: 0.9).delay(0.1)) {
                    ringAnimated = true
                }
            }
            .navigationDestination(isPresented: $showSettings) {
                if let settingsViewModel {
                    SettingsView(viewModel: settingsViewModel)
                }
            }
            .onChange(of: showSettings) { _, isShown in
                if !isShown {
                    Task { await viewModel.load() }
                }
            }
        }
    }

    // MARK: - Ring

    private var ringSection: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.1), lineWidth: 18)

            Circle()
                .trim(from: 0, to: ringAnimated ? viewModel.progress : 0)
                .stroke(viewModel.isOverTarget ? .orange : .green, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.7), value: viewModel.progress)

            VStack(spacing: 0) {
                Text(viewModel.isOverTarget ? "OVER BY" : "EATEN")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(Color.primary.opacity(0.6))

                Text(viewModel.isOverTarget ? "+\((viewModel.eaten - viewModel.target).formatted())" : viewModel.eaten.formatted())
                    .font(.system(size: 52, weight: .semibold, design: .rounded))
                    .tracking(-1.5)
                    .monospacedDigit()
                    .foregroundStyle(viewModel.isOverTarget ? Color.orange : Color.primary)
                    .padding(.top, 2)
                    .contentTransition(.numericText(value: Double(viewModel.eaten)))
                    .animation(.snappy, value: viewModel.eaten)

                Text("of \(viewModel.target.formatted()) kcal")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.primary.opacity(0.6))
                    .padding(.top, 6)
            }
        }
        .frame(width: 240, height: 240)
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    // MARK: - Stat Strip

    private var statStrip: some View {
        HStack {
            statItem(value: viewModel.target.formatted(), label: "TARGET")
            statItem(
                value: viewModel.isOverTarget ? "+\((viewModel.eaten - viewModel.target).formatted())" : viewModel.remaining.formatted(),
                label: viewModel.isOverTarget ? "OVER" : "REMAINING",
                warn: viewModel.isOverTarget
            )
            statItem(value: "\(viewModel.meals.count)", label: "MEALS")
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .glassEffect()
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private func statItem(value: String, label: String, warn: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .tracking(-0.5)
                .monospacedDigit()
                .foregroundStyle(warn ? Color.orange : Color.primary)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(Color.primary.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Meals

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("MEALS · \(viewModel.eaten.formatted()) KCAL")
                .font(.system(size: 13, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(Color.primary.opacity(0.6))
                .padding(.horizontal, 4)
                .padding(.bottom, 8)



            VStack(spacing: 0) {
                ForEach(Array(viewModel.meals.enumerated()), id: \.element.id) { index, meal in
                    SwipeToDeleteRow {
                        Task { await viewModel.delete(meal) }
                    } content: {
                        mealRow(meal, isLast: index == viewModel.meals.count - 1)
                            .padding(.horizontal, 18)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .padding(.horizontal, 20)
    }

    private func mealRow(_ meal: Meal, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(meal.name)
                        .font(.system(size: 17, weight: .medium))
                        .tracking(-0.4)
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)

                    Text("\(meal.timeString) · \(meal.grams)g")
                        .font(.system(size: 13))
                        .tracking(-0.08)
                        .foregroundStyle(Color.primary.opacity(0.6))
                }

                Spacer()

                Text("\(meal.kcal)")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .tracking(-0.4)
                    .monospacedDigit()
                    .foregroundStyle(Color.primary)
            }
            .padding(.vertical, 14)

            if !isLast {
                Rectangle()
                    .fill(Color.primary.opacity(0.12))
                    .frame(height: 0.5)
            }
        }
    }

    // MARK: - FAB

    private var fab: some View {
        Button {
            showAddMeal = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.primary)
                .frame(width: 50, height: 60)
        }
        .buttonStyle(.glass)
        .padding(.trailing, 20)
        .padding(.bottom, 52)
        .sheet(
            isPresented: $showAddMeal,
            onDismiss: { Task { await viewModel.load() } }
        ) {
            AddMealView(viewModel: viewModel.makeAddMealViewModel())
        }
    }
}

#Preview("Default") {
    HomeView(viewModel: HomeViewModel(
        mealStore: InMemoryMealStore(meals: .sample),
        calorieEstimator: StubCalorieEstimator(),
        settingsStore: InMemorySettingsStore()
    ))
}

#Preview("On Target") {
    HomeView(viewModel: HomeViewModel(
        mealStore: InMemoryMealStore(meals: .onTarget),
        calorieEstimator: StubCalorieEstimator(),
        settingsStore: InMemorySettingsStore()
    ))
}

#Preview("Over Target") {
    HomeView(viewModel: HomeViewModel(
        mealStore: InMemoryMealStore(meals: .overTarget),
        calorieEstimator: StubCalorieEstimator(),
        settingsStore: InMemorySettingsStore()
    ))
}

#Preview("Empty") {
    HomeView(viewModel: HomeViewModel(
        mealStore: InMemoryMealStore(meals: .empty),
        calorieEstimator: StubCalorieEstimator(),
        settingsStore: InMemorySettingsStore()
    ))
}
