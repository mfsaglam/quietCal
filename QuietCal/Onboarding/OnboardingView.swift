import SwiftUI

// MARK: - View Model

@MainActor
@Observable
final class OnboardingViewModel {
    private let settingsStore: SettingsStore

    /// The daily calorie target chosen during onboarding. Pre-loaded from the
    /// store so a returning user (replaying the intro) sees their current value.
    var target: Int = AppGroup.defaultTarget

    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore
    }

    func load() async {
        if let loaded = try? await settingsStore.loadTarget() {
            target = loaded
        }
    }

    /// Persists the chosen target and refreshes widgets. Called when the flow
    /// completes (either by finishing or skipping).
    func persistTarget() {
        let value = target
        Task {
            try? await settingsStore.saveTarget(value)
            AppGroup.reloadWidgets()
        }
    }
}

// MARK: - Container

struct OnboardingView: View {
    @Bindable var viewModel: OnboardingViewModel
    var onComplete: () -> Void

    @State private var step = 0
    private let lastStep = 4

    var body: some View {
        VStack(spacing: 0) {
            topBar

            TabView(selection: $step) {
                WelcomeStep().tag(0)
                TargetStep(target: $viewModel.target).tag(1)
                EstimatesStep().tag(2)
                WidgetsStep().tag(3)
                ReadyStep(target: viewModel.target).tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: step)

            footer
        }
        .background(Color(.systemBackground))
        .task { await viewModel.load() }
    }

    // MARK: Top bar

    private var showsSkip: Bool { step >= 1 && step <= 3 }

    private var topBar: some View {
        HStack {
            Spacer()
            if showsSkip {
                Button("Skip") { complete() }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 22)
    }

    // MARK: Footer

    private var footer: some View {
        VStack(spacing: 22) {
            PageDots(count: 5, active: step)

            Button(action: primaryAction) {
                Text(primaryLabel)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(.systemBackground))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.primary, in: RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)

            if let secondaryText {
                Text(secondaryText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private var primaryLabel: String {
        switch step {
        case 0: return "Get started"
        case lastStep: return "Start tracking"
        default: return "Continue"
        }
    }

    private var secondaryText: String? {
        switch step {
        case 0: return "A few quick steps · under a minute"
        case 3: return "Add later from the widget gallery"
        default: return nil
        }
    }

    private func primaryAction() {
        if step < lastStep {
            withAnimation(.easeInOut(duration: 0.3)) { step += 1 }
        } else {
            complete()
        }
    }

    private func complete() {
        viewModel.persistTarget()
        onComplete()
    }
}

// MARK: - Shared components

private struct PageDots: View {
    let count: Int
    let active: Int

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == active ? Color.primary : Color.primary.opacity(0.18))
                    .frame(width: index == active ? 22 : 7, height: 7)
                    .animation(.easeInOut(duration: 0.24), value: active)
            }
        }
    }
}

/// A calorie ring matching the Home screen's style, with arbitrary centre content.
private struct OnboardingRing<Content: View>: View {
    var progress: Double
    var lineWidth: CGFloat
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.1), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(progress, 0.0001))
                .stroke(Color.green, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            content()
        }
    }
}

private let appleIntelligenceGradient = LinearGradient(
    colors: [
        Color(red: 0.686, green: 0.322, blue: 0.871),
        Color(red: 1.0, green: 0.176, blue: 0.573)
    ],
    startPoint: .leading,
    endPoint: .trailing
)

private struct AppleIntelligenceLabel: View {
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
            Text("APPLE INTELLIGENCE")
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.5)
        }
        .foregroundStyle(appleIntelligenceGradient)
    }
}

// MARK: - 1 · Welcome

private struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            OnboardingRing(progress: 0.72, lineWidth: 12) {
                Text("Q")
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .frame(width: 132, height: 132)
            .padding(.bottom, 40)

            Text(AppInfo.name.uppercased())
                .font(.system(size: 13, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(.secondary)
                .padding(.bottom, 14)

            Text("Calorie tracking,\nquietly.")
                .font(.system(size: 38, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text("Log a meal, get an instant estimate, watch one ring. No macros, no streaks, no noise.")
                .font(.system(size: 17))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 18)
                .frame(maxWidth: 300)

            Spacer()
        }
        .padding(.horizontal, 36)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 2 · Set daily target

private struct TargetStep: View {
    @Binding var target: Int

    private let range: ClosedRange<Double> = 1200...3500
    private let presets = [1500, 1800, 2000, 2200, 2500, 2800]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Set your daily target")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Pick a number to aim for each day. You can change it anytime in Settings.")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)

                VStack(spacing: 8) {
                    Text(target.formatted())
                        .font(.system(size: 88, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: target)
                    Text("KCAL PER DAY")
                        .font(.system(size: 13, weight: .medium))
                        .tracking(0.5)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

                VStack(spacing: 10) {
                    Slider(value: sliderBinding, in: range, step: 50)
                    HStack {
                        Text(Int(range.lowerBound).formatted())
                        Spacer()
                        Text(Int(range.upperBound).formatted())
                    }
                    .font(.system(size: 12))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                }
                .padding(22)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22))

                Text("QUICK PICK")
                    .font(.system(size: 13, weight: .medium))
                    .tracking(0.5)
                    .foregroundStyle(.secondary)
                    .padding(.top, 20)
                    .padding(.leading, 4)

                presetChips
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    private var presetChips: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(presets.prefix(3), id: \.self) { chip($0) }
                Spacer(minLength: 0)
            }
            HStack(spacing: 8) {
                ForEach(presets.suffix(3), id: \.self) { chip($0) }
                Spacer(minLength: 0)
            }
        }
    }

    private func chip(_ value: Int) -> some View {
        let selected = target == value
        return Button {
            target = value
        } label: {
            Text(value.formatted())
                .font(.system(size: 15, weight: .medium))
                .monospacedDigit()
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    selected ? Color.primary : Color(.secondarySystemBackground),
                    in: Capsule()
                )
                .foregroundStyle(selected ? Color(.systemBackground) : Color.primary)
        }
        .buttonStyle(.plain)
    }

    private var sliderBinding: Binding<Double> {
        Binding(
            get: { Double(target) },
            set: { target = Int($0) }
        )
    }
}

// MARK: - 3 · How estimates work

private struct EstimatesStep: View {
    private let steps: [(title: String, detail: String)] = [
        ("Type what you ate", "A name and a rough amount — “chicken salad, 340g.”"),
        ("Get an instant estimate", "Apple Intelligence estimates the calories on device."),
        ("Retry if needed", "Not sure about an estimate? Tap to retry it.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AppleIntelligenceLabel()
                    .padding(.bottom, 12)

                Text("How estimates work")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)

                Text("No databases to search or barcodes to scan. Just describe the meal.")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)

                estimateCard
                    .padding(.top, 24)

                VStack(alignment: .leading, spacing: 18) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 14) {
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary)
                                .frame(width: 26, height: 26)
                                .background(Color.primary.opacity(0.07), in: Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                Text(item.detail)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, 28)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    private var estimateCard: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Chicken salad")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.primary)
                    Text("340 g")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("520")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                    Text("kcal")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            HStack(spacing: 7) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundStyle(appleIntelligenceGradient)
                Text("Estimated by Apple Intelligence · tap to retry")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22))
    }
}

// MARK: - 4 · Widgets

private struct WidgetsStep: View {
    private let tags = ["Home Screen", "Lock Screen", "StandBy"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Keep it one glance away")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Add a widget to see your ring without opening the app — and log a meal in one tap.")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)

                showcase
                    .padding(.top, 26)

                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color.primary.opacity(0.06), in: Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 18)
            }
            .padding(.horizontal, 28)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    private var showcase: some View {
        VStack(spacing: 18) {
            MockMediumWidget()
            MockSmallWidget()
        }
        .padding(.vertical, 26)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.851, green: 0.886, blue: 0.941),
                    Color(red: 0.914, green: 0.894, blue: 0.933),
                    Color(red: 0.953, green: 0.925, blue: 0.894)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28)
        )
        // The wallpaper-style panel is always light, so render the mock widgets
        // in light mode regardless of the app's appearance for legible contrast.
        .environment(\.colorScheme, .light)
    }
}

/// A non-interactive replica of the small calorie widget, for the showcase only.
private struct MockSmallWidget: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("TODAY")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            ZStack {
                Circle().stroke(Color.primary.opacity(0.1), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: 0.62)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 1) {
                    Text("1,240")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                    Text("of 2,000")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }

            Text("760 kcal left")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(width: 150, height: 150)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22))
    }
}

/// A non-interactive replica of the medium calorie widget, for the showcase only.
private struct MockMediumWidget: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().stroke(Color.primary.opacity(0.1), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: 0.62)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("1,240")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                    Text("of 2,000")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 96, height: 96)

            VStack(alignment: .leading, spacing: 0) {
                Text("TODAY")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(.secondary)
                Text("760")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .padding(.top, 2)
                Text("kcal remaining")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                Spacer(minLength: 8)

                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("Log meal")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(Color(.systemBackground))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.primary, in: RoundedRectangle(cornerRadius: 12))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(width: 320, height: 148)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22))
    }
}

// MARK: - 5 · Ready

private struct ReadyStep: View {
    let target: Int

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            OnboardingRing(progress: 0.001, lineWidth: 16) {
                VStack(spacing: 2) {
                    Text("EATEN")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .tracking(0.5)
                        .foregroundStyle(.secondary)
                    Text("0")
                        .font(.system(size: 52, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("of \(target.formatted()) kcal")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                }
            }
            .frame(width: 200, height: 200)
            .padding(.bottom, 36)

            Text("You're all set")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.primary)

            Text("Your ring starts fresh. Tap **+** to log your first meal whenever you're ready.")
                .font(.system(size: 17))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .frame(maxWidth: 300)

            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

#Preview("Onboarding") {
    OnboardingView(
        viewModel: OnboardingViewModel(settingsStore: InMemorySettingsStore()),
        onComplete: {}
    )
}
