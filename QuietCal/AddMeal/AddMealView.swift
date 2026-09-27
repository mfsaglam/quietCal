import SwiftUI

struct AddMealView: View {
    @Bindable var viewModel: AddMealViewModel

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    @State private var showPaywall = false

    private enum Field { case name, amount }

    private let aiPurple = Color(red: 175/255, green: 82/255, blue: 222/255)
    private let aiPink = Color(red: 255/255, green: 45/255, blue: 146/255)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    nameField
                    HStack(spacing: 10) {
                        amountField
                        caloriesField
                    }
                    if viewModel.state == .estimated {
                        aiChip
                    }
                    if viewModel.state == .failed {
                        errorChip
                    }
                    unitPicker
                    if viewModel.state == .estimated, !viewModel.estimatedIngredients.isEmpty {
                        ingredientsSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("New Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if await viewModel.save() == .blockedByLimit {
                                showPaywall = true
                            } else {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .task(id: estimateTaskID) {
                do {
                    try await Task.sleep(for: .milliseconds(600))
                } catch {
                    return
                }
                await viewModel.estimate()
            }
            .onAppear { focusedField = .name }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var estimateTaskID: String {
        "\(viewModel.name)|\(viewModel.amount)|\(viewModel.unit.rawValue)"
    }

    // MARK: - Fields

    private var nameField: some View {
        fieldCard(label: "NAME") {
            TextField("e.g. Chicken salad", text: $viewModel.name)
                .font(.system(size: 17))
                .tracking(-0.4)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled(false)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit { focusedField = .amount }
        }
    }

    private var amountField: some View {
        fieldCard(label: "AMOUNT") {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                TextField("—", text: $viewModel.amount)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .tracking(-0.5)
                    .monospacedDigit()
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .amount)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(viewModel.unit.label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var caloriesField: some View {
        switch viewModel.state {
        case .empty:
            fieldCard(label: "CALORIES", sparkleLabel: true) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("—")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text("kcal")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        case .estimating:
            fieldCard(label: "ESTIMATING…", sparkleLabel: true, labelColor: aiPurple) {
                ShimmerBar(start: aiPurple, end: aiPink)
            }
        case .estimated:
            fieldCard(label: "CALORIES", sparkleLabel: true) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(viewModel.estimatedCalories ?? 0)")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .tracking(-0.5)
                        .monospacedDigit()
                    Text("kcal")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        case .failed:
            fieldCard(label: "CALORIES", labelColor: .orange) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.orange)
                    Text("Failed")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    private var aiChip: some View {
        HStack(spacing: 8) {
            sparkle(size: 14)
            VStack(alignment: .leading, spacing: 1) {
                Text(viewModel.estimationSource.label)
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(-0.1)
                if let confidence = viewModel.estimatedConfidence {
                    Text(confidence.label)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(aiPurple.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(aiPurple.opacity(0.25), lineWidth: 0.5)
        }
    }

    private var errorChip: some View {
        Button {
            Task { await viewModel.retry() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Couldn't estimate calories")
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(-0.1)
                    Text(viewModel.errorMessage ?? "Tap to try again")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14))
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange.opacity(0.25), lineWidth: 0.5)
            }
        }
        .buttonStyle(.plain)
    }

    private var unitPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("UNIT")
                .font(.system(size: 11, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            Picker("Unit", selection: $viewModel.unit) {
                ForEach(WeightUnit.allCases) { unit in
                    Text(unit.label).tag(unit)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.top, 4)
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Estimated ingredients", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button("Edit name") { focusedField = .name }
                    .font(.subheadline.weight(.medium))
            }
            IngredientPillLayout(spacing: 8) {
                ForEach(Array(viewModel.estimatedIngredients.enumerated()), id: \.offset) { _, ingredient in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(ingredient.name)
                            .font(.subheadline.weight(.medium))
                        Text("\(ingredient.grams) g · \(ingredient.calories) kcal")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(aiPurple.opacity(0.07), in: RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(aiPurple.opacity(0.15), lineWidth: 0.5)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            Text("Not quite right? Add details to the dish name to update the estimate.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func fieldCard<Content: View>(
        label: String,
        sparkleLabel: Bool = false,
        labelColor: Color = .secondary,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                if sparkleLabel { sparkle(size: 11) }
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .tracking(0.5)
                    .foregroundStyle(labelColor)
            }
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func sparkle(size: CGFloat) -> some View {
        Image(systemName: "sparkles")
            .font(.system(size: size))
            .foregroundStyle(
                LinearGradient(colors: [aiPurple, aiPink],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
    }
}

/// Wraps pills to the available width, including at larger text sizes.
private struct IngredientPillLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(subviews, width: proposal.width ?? 320).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let arrangement = arrange(subviews, width: bounds.width)
        for (index, subview) in subviews.enumerated() {
            let frame = arrangement.frames[index]
            subview.place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                          proposal: ProposedViewSize(width: frame.width, height: frame.height))
        }
    }

    private func arrange(_ subviews: Subviews, width: CGFloat) -> (size: CGSize, frames: [CGRect]) {
        let width = max(0, width)
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let ideal = subview.sizeThatFits(.unspecified)
            let size = subview.sizeThatFits(ProposedViewSize(width: min(ideal.width, width), height: nil))
            if x > 0, x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return (CGSize(width: width, height: y + rowHeight), frames)
    }
}

private struct ShimmerBar: View {
    let start: Color
    let end: Color
    @State private var animate = false

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                LinearGradient(
                    colors: [start.opacity(0.18), end.opacity(0.18), start.opacity(0.18)],
                    startPoint: animate ? .trailing : .leading,
                    endPoint: animate ? UnitPoint(x: 2, y: 0.5) : UnitPoint(x: 1, y: 0.5)
                )
            )
            .frame(height: 28)
            .onAppear {
                withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
    }
}

#Preview("Add Meal") {
    @Previewable @State var presented = true

    Color.gray.opacity(0.2)
        .ignoresSafeArea()
        .sheet(isPresented: $presented) {
            AddMealView(
                viewModel: AddMealViewModel(
                    mealStore: InMemoryMealStore(meals: .sample),
                    calorieEstimator: StubCalorieEstimator()
                )
            )
        }
}

#Preview("Estimated ingredients") {
    let model = AddMealViewModel(
        mealStore: InMemoryMealStore(meals: []),
        calorieEstimator: IngredientPreviewEstimator()
    )
    model.name = "Chicken salad"
    model.amount = "250"
    return AddMealView(viewModel: model)
}

private struct IngredientPreviewEstimator: CalorieEstimating {
    let source: CalorieEstimationSource = .appleIntelligence

    func estimate(name: String, grams: Int) async throws -> CalorieEstimate {
        CalorieEstimate(calories: 310, confidence: .medium, ingredients: [
            EstimatedIngredient(name: "Grilled chicken", grams: 100, calories: 165),
            EstimatedIngredient(name: "Mixed greens", grams: 80, calories: 16),
            EstimatedIngredient(name: "Cherry tomatoes", grams: 50, calories: 9),
            EstimatedIngredient(name: "Olive oil dressing", grams: 20, calories: 120)
        ])
    }
}
