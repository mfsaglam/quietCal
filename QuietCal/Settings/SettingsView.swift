import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let viewModel: SettingsViewModel

    @State private var showResetTodayConfirm = false
    @State private var showClearAllConfirm = false
    @State private var showExporter = false
    @State private var exportDocument: CSVDocument?

    var body: some View {
        List {
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
                Picker(selection: weightUnitBinding) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.settingsLabel).tag(unit)
                    }
                } label: {
                    Text("Weight unit")
                        .foregroundStyle(.primary)
                }
                .pickerStyle(.navigationLink)
            }

            Section("Appearance") {
                Picker(selection: themeBinding) {
                    ForEach(Theme.allCases) { theme in
                        Text(theme.label).tag(theme)
                    }
                } label: {
                    Text("Theme")
                        .foregroundStyle(.primary)
                }
                .pickerStyle(.navigationLink)
            }

            Section("Data") {
                Button {
                    Task {
                        let csv = await viewModel.generateCSV()
                        exportDocument = CSVDocument(text: csv)
                        showExporter = true
                    }
                } label: {
                    HStack {
                        Text("Export CSV")
                            .foregroundStyle(.primary)
                        Spacer()
                        chevron
                    }
                }

                Button {
                    showResetTodayConfirm = true
                } label: {
                    HStack {
                        Text("Reset today")
                            .foregroundStyle(.primary)
                        Spacer()
                        chevron
                    }
                }

                Button("Clear all data", role: .destructive) {
                    showClearAllConfirm = true
                }
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
        .alert("Reset today's meals?", isPresented: $showResetTodayConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                Task { await viewModel.resetToday() }
            }
        } message: {
            Text("This will permanently delete every meal logged today.")
        }
        .alert("Clear all data?", isPresented: $showClearAllConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                Task { await viewModel.clearAll() }
            }
        } message: {
            Text("This will permanently delete every meal you've ever logged. This cannot be undone.")
        }
        .fileExporter(
            isPresented: $showExporter,
            document: exportDocument,
            contentType: .commaSeparatedText,
            defaultFilename: "quietcal-meals"
        ) { _ in
            exportDocument = nil
        }
    }

    private var themeBinding: Binding<Theme> {
        Binding(
            get: { viewModel.theme },
            set: { viewModel.updateTheme($0) }
        )
    }

    private var weightUnitBinding: Binding<WeightUnit> {
        Binding(
            get: { viewModel.weightUnit },
            set: { viewModel.updateWeightUnit($0) }
        )
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.tertiary)
    }
}

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.commaSeparatedText]

    var text: String

    init(text: String) {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel(
            store: InMemorySettingsStore(),
            mealStore: InMemoryMealStore(meals: .sample)
        ))
    }
}
