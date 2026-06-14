import SwiftUI

struct EditTargetView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var target: Double = 2000

    private let range: ClosedRange<Double> = 1200...3500
    private let presets: [Int] = [1500, 1800, 2000, 2200, 2500, 2800]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                bigNumber
                sliderCard
                presetSection
            }
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Daily target")
                .font(.system(size: 34, weight: .bold))
                .tracking(0.4)
                .foregroundStyle(.primary)
            Text("How many calories per day?")
                .font(.system(size: 15))
                .tracking(-0.2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
    }

    private var bigNumber: some View {
        VStack(spacing: 6) {
            Text(Int(target).formatted())
                .font(.system(size: 96, weight: .semibold, design: .rounded))
                .tracking(-3)
                .monospacedDigit()
                .foregroundStyle(.primary)
            Text("KCAL PER DAY")
                .font(.system(size: 13, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
        .padding(.bottom, 24)
    }

    private var sliderCard: some View {
        VStack(spacing: 10) {
            Slider(value: $target, in: range, step: 50)
            HStack {
                Text(Int(range.lowerBound).formatted())
                Spacer()
                Text(Int(range.upperBound).formatted())
            }
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
        .padding(22)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22))
        .padding(.horizontal, 20)
    }

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("QUICK PICK")
                .font(.system(size: 13, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    chip(1500); chip(1800); chip(2000)
                    Spacer(minLength: 0)
                }
                HStack(spacing: 8) {
                    chip(2200); chip(2500); chip(2800)
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private func chip(_ preset: Int) -> some View {
        let isSelected = Int(target) == preset
        return Button {
            target = Double(preset)
        } label: {
            Text(preset.formatted())
                .font(.system(size: 15, weight: .medium))
                .monospacedDigit()
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    isSelected ? Color.primary : Color(.secondarySystemBackground),
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? Color(.systemBackground) : Color.primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        EditTargetView()
    }
}
