import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let viewModel: SettingsViewModel

    @Environment(StoreKitEntitlementStore.self) private var entitlements

    @State private var showResetTodayConfirm = false
    @State private var showClearAllConfirm = false
    @State private var showIntroResetAlert = false
    @State private var showExporter = false
    @State private var exportDocument: CSVDocument?
    @State private var showPaywall = false

    @State private var selectedWeightUnit: WeightUnit = .g
    @State private var selectedTheme: Theme = .system
    @State private var didLoad = false

    var body: some View {
        List {
            proSection

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
                Picker(selection: $selectedWeightUnit) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.settingsLabel).tag(unit)
                    }
                } label: {
                    Text("Weight unit")
                        .foregroundStyle(.primary)
                }
                .pickerStyle(.navigationLink)
                .onChange(of: selectedWeightUnit) { _, newValue in
                    guard didLoad else { return }
                    viewModel.updateWeightUnit(newValue)
                }
            }

            Section("Appearance") {
                Picker(selection: $selectedTheme) {
                    ForEach(Theme.allCases) { theme in
                        themeRow(theme).tag(theme)
                    }
                } label: {
                    Text("Theme")
                        .foregroundStyle(.primary)
                }
                .pickerStyle(.navigationLink)
                .onChange(of: selectedTheme) { _, newValue in
                    guard didLoad else { return }
                    // Light and Dark are Pro-only; System stays free. If a free
                    // user picks a locked theme, revert to System and surface the
                    // paywall instead of applying it.
                    if !entitlements.isPro, newValue != .system {
                        selectedTheme = .system
                        showPaywall = true
                        return
                    }
                    viewModel.updateTheme(newValue)
                }
            }

            Section("About") {
                Button {
                    AppGroup.sharedDefaults.set(false, forKey: AppGroup.onboardingCompletedKey)
                    showIntroResetAlert = true
                } label: {
                    HStack {
                        Text("Show intro again")
                            .foregroundStyle(.primary)
                        Spacer()
                        chevron
                    }
                }
            }

            Section("Data") {
                Button {
                    guard entitlements.isPro else {
                        showPaywall = true
                        return
                    }
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
                        if entitlements.isPro {
                            chevron
                        } else {
                            proLock
                        }
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
                Text(AppInfo.nameAndVersion)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .task {
            guard !didLoad else { return }
            await viewModel.load()
            selectedWeightUnit = viewModel.weightUnit
            selectedTheme = viewModel.theme
            didLoad = true
        }
        .alert("Intro reset", isPresented: $showIntroResetAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The intro will be shown the next time you launch the app.")
        }
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

    // MARK: - Pro

    @ViewBuilder
    private var proSection: some View {
        if entitlements.isPro {
            Section("QuietCal Pro") {
                HStack {
                    Label("QuietCal Pro", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("Active")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            Section("QuietCal Pro") {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Label("Upgrade to Pro", systemImage: "sparkles")
                            .foregroundStyle(.primary)
                        Spacer()
                        chevron
                    }
                }
                Button("Restore purchases") {
                    Task { await entitlements.restore() }
                }
                .foregroundStyle(.primary)
            }
        }
    }

    /// A theme picker row, badged with a lock for Pro-only themes when the user
    /// isn't subscribed.
    @ViewBuilder
    private func themeRow(_ theme: Theme) -> some View {
        if !entitlements.isPro, theme != .system {
            HStack {
                Text(theme.label)
                Spacer()
                proLock
            }
        } else {
            Text(theme.label)
        }
    }

    private var proLock: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: 13))
            .foregroundStyle(.tertiary)
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
    .environment(StoreKitEntitlementStore(previewIsPro: false))
}
