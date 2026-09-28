import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let viewModel: SettingsViewModel
    /// Passed in explicitly rather than read from the environment: Settings is
    /// reached through a `navigationDestination`, and `@Observable` environment
    /// objects don't reliably propagate across that boundary.
    let entitlements: StoreKitEntitlementStore

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

            Section("settings.section.daily_target") {
                NavigationLink {
                    EditTargetView(viewModel: viewModel)
                } label: {
                    HStack {
                        Text("settings.calorie_target")
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
                    Text("settings.weight_unit")
                        .foregroundStyle(.primary)
                }
                .pickerStyle(.navigationLink)
                .onChange(of: selectedWeightUnit) { _, newValue in
                    guard didLoad else { return }
                    viewModel.updateWeightUnit(newValue)
                }
            }

            Section("settings.section.appearance") {
                Picker(selection: $selectedTheme) {
                    ForEach(Theme.allCases) { theme in
                        themeRow(theme).tag(theme)
                    }
                } label: {
                    Text("settings.theme")
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

            Section("settings.section.about") {
                Button {
                    AppGroup.sharedDefaults.set(false, forKey: AppGroup.onboardingCompletedKey)
                    showIntroResetAlert = true
                } label: {
                    HStack {
                        Text("settings.show_intro")
                            .foregroundStyle(.primary)
                        Spacer()
                        chevron
                    }
                }
            }

            Section("settings.section.data") {
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
                        Text("settings.export_csv")
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
                        Text("settings.reset_today")
                            .foregroundStyle(.primary)
                        Spacer()
                        chevron
                    }
                }

                Button("settings.clear_all", role: .destructive) {
                    showClearAllConfirm = true
                }
            }

            developerSection

            legalSection

            Section {
                Text(AppInfo.nameAndVersion)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("common.settings")
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
        .alert("settings.alert.intro_reset.title", isPresented: $showIntroResetAlert) {
            Button("common.ok", role: .cancel) { }
        } message: {
            Text("settings.alert.intro_reset.message")
        }
        .alert("settings.alert.reset_today.title", isPresented: $showResetTodayConfirm) {
            Button("common.cancel", role: .cancel) { }
            Button("common.reset", role: .destructive) {
                Task { await viewModel.resetToday() }
            }
        } message: {
            Text("settings.alert.reset_today.message")
        }
        .alert("settings.alert.clear_all.title", isPresented: $showClearAllConfirm) {
            Button("common.cancel", role: .cancel) { }
            Button("common.clear", role: .destructive) {
                Task { await viewModel.clearAll() }
            }
        } message: {
            Text("settings.alert.clear_all.message")
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

    private var legalSection: some View {
        Section("settings.section.legal") {
            legalLink(
                "settings.privacy_policy",
                systemImage: "hand.raised",
                destination: AppInfo.privacyPolicyURL
            )
            legalLink(
                "settings.terms_of_use",
                systemImage: "doc.text",
                destination: AppInfo.termsOfUseURL
            )
        }
    }

    private func legalLink(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        destination: URL
    ) -> some View {
        Link(destination: destination) {
            HStack {
                Label(titleKey, systemImage: systemImage)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Developer (debug only)

    @ViewBuilder
    private var developerSection: some View {
        #if DEBUG
        Section {
            Toggle("settings.debug.pro_toggle", isOn: debugProBinding)
        } header: {
            Text("settings.debug.title")
        } footer: {
            Text("settings.debug.message")
        }
        #endif
    }

    #if DEBUG
    private var debugProBinding: Binding<Bool> {
        Binding(
            get: { entitlements.isPro },
            set: { entitlements.setDebugPro($0) }
        )
    }
    #endif

    // MARK: - Pro

    @ViewBuilder
    private var proSection: some View {
        if entitlements.isPro {
            Section("pro.name") {
                HStack {
                    Label("pro.name", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("settings.pro.active")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            Section("pro.name") {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Label("settings.pro.upgrade", systemImage: "sparkles")
                            .foregroundStyle(.primary)
                        Spacer()
                        chevron
                    }
                }
                Button("settings.pro.restore_purchases") {
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
        SettingsView(
            viewModel: SettingsViewModel(
                store: InMemorySettingsStore(),
                mealStore: InMemoryMealStore(meals: .sample)
            ),
            entitlements: StoreKitEntitlementStore(previewIsPro: false)
        )
    }
}
