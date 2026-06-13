import SwiftUI

struct AddMealView: View {
    enum FieldState { case empty, estimating, estimated }

    var state: FieldState = .estimated

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    nameField
                    HStack(spacing: 10) {
                        amountField
                        caloriesField
                    }
                    if state == .estimated {
                        aiChip
                    }
                    unitPicker
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("New Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                        .disabled(state != .estimated)
                }
            }
        }
        .presentationDetents([.fraction(0.78), .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Fields

    private var nameField: some View {
        fieldCard(label: "NAME") {
            Text(state == .empty ? "Chick" : "Chicken salad")
                .font(.system(size: 17))
                .tracking(-0.4)
        }
    }

    private var amountField: some View {
        fieldCard(label: "AMOUNT") {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(state == .empty ? "—" : "340")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .tracking(-0.5)
                    .monospacedDigit()
                    .foregroundStyle(state == .empty ? Color.secondary : Color.primary)
                Text("g")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var caloriesField: some View {
        switch state {
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
            fieldCard(label: "ESTIMATING…", sparkleLabel: true, labelColor: .purple) {
                ShimmerBar(start: .purple, end: .pink)
            }
        case .estimated:
            fieldCard(label: "CALORIES", sparkleLabel: true) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("520")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .tracking(-0.5)
                        .monospacedDigit()
                    Text("kcal")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var aiChip: some View {
        HStack(spacing: 8) {
            sparkle(size: 14)
            VStack(alignment: .leading, spacing: 1) {
                Text("Estimated by Apple Intelligence")
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(-0.1)
                Text("Medium confidence · tap to edit or retry")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 14))
                .foregroundStyle(.purple)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.purple.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.purple.opacity(0.25), lineWidth: 0.5)
        }
    }

    private var unitPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("UNIT")
                .font(.system(size: 11, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            Picker("Unit", selection: .constant(0)) {
                Text("g").tag(0)
                Text("oz").tag(1)
                Text("lb").tag(2)
            }
            .pickerStyle(.segmented)
        }
        .padding(.top, 4)
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
                LinearGradient(colors: [.purple, .pink],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
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

#Preview("Empty") {
    AddMealPreviewWrapper(state: .empty)
}

#Preview("Estimating") {
    AddMealPreviewWrapper(state: .estimating)
}

#Preview("Estimated") {
    AddMealPreviewWrapper(state: .estimated)
}

private struct AddMealPreviewWrapper: View {
    let state: AddMealView.FieldState
    @State private var presented = true

    var body: some View {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
            .sheet(isPresented: $presented) {
                AddMealView(state: state)
            }
    }
}
