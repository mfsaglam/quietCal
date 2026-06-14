import SwiftUI

struct SettingsView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("Intelligence") {
                valueRow(label: "Auto-estimate calories", value: "On")
                valueRow(label: "Cloud fallback", value: "Off")
            }

            Section("Daily Target") {
                NavigationLink {
                    EditTargetView(viewModel: viewModel)
                } label: {
                    HStack {
                        Text("Calorie target")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(viewModel.formattedTarget)
                            .foregroundStyle(.secondary)
                    }
                }
                valueRow(label: "Weight unit", value: "Grams")
            }

            Section("Appearance") {
                valueRow(label: "Theme", value: "System")
                valueRow(label: "Accent", value: "Ink")
            }

            Section("Data") {
                actionRow(label: "Export CSV")
                actionRow(label: "Reset today")
                Button("Clear all data", role: .destructive) { }
            }

            Section {
                Text("Quiet Kcal · v1.0")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Settings")
        .task { await viewModel.load() }
    }

    private func valueRow(label: String, value: String) -> some View {
        Button { } label: {
            HStack {
                Text(label)
                    .foregroundStyle(.primary)
                Spacer()
                Text(value)
                    .foregroundStyle(.secondary)
                chevron
            }
        }
    }

    private func actionRow(label: String) -> some View {
        Button { } label: {
            HStack {
                Text(label)
                    .foregroundStyle(.primary)
                Spacer()
                chevron
            }
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.tertiary)
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel(store: InMemorySettingsStore()))
    }
}
