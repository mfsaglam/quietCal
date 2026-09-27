import SwiftUI
import UIKit

/// Shown in place of the app when on-device calorie estimation can't run.
/// QuietCal relies on Apple Intelligence to estimate calories, so when the
/// model is unavailable the app explains why and — where the situation is
/// recoverable — offers a way forward.
struct ModelUnavailableView: View {
    let availability: ModelAvailability
    /// Re-checks availability. Used by "Check Again" once the user has, e.g.,
    /// enabled Apple Intelligence or let the model finish downloading.
    var onRetry: () -> Void

    @Environment(\.openURL) private var openURL

    private static let gradient = LinearGradient(
        colors: [
            Color(red: 0.686, green: 0.322, blue: 0.871),
            Color(red: 1.0, green: 0.176, blue: 0.573)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: iconName)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(Self.gradient)
                .padding(.bottom, 28)

            Text(title)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text(message)
                .font(.system(size: 17))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .frame(maxWidth: 320)

            Spacer()

            actions
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    // MARK: - Actions

    @ViewBuilder
    private var actions: some View {
        VStack(spacing: 12) {
            if showsSettingsButton {
                Button(action: openSettings) {
                    primaryLabel("model_unavailable.action.open_settings")
                }
                .buttonStyle(.plain)

                Button("model_unavailable.action.check_again", action: onRetry)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
            } else if showsRetryButton {
                Button(action: onRetry) {
                    primaryLabel("model_unavailable.action.check_again")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func primaryLabel(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(Color(.systemBackground))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.primary, in: RoundedRectangle(cornerRadius: 18))
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }

    // MARK: - Per-reason content

    /// `deviceNotEligible` is permanent, so it offers no action.
    private var showsSettingsButton: Bool {
        availability == .appleIntelligenceNotEnabled
    }

    private var showsRetryButton: Bool {
        availability == .modelNotReady || availability == .unknown
    }

    private var iconName: String {
        switch availability {
        case .appleIntelligenceNotEnabled: "sparkles"
        case .modelNotReady: "arrow.down.circle"
        case .deviceNotEligible: "exclamationmark.triangle"
        default: "sparkles"
        }
    }

    private var title: String {
        switch availability {
        case .appleIntelligenceNotEnabled:
            L10n.string("model_unavailable.not_enabled.title")
        case .modelNotReady:
            L10n.string("model_unavailable.not_ready.title")
        case .deviceNotEligible:
            L10n.string("model_unavailable.not_supported.title")
        default:
            L10n.string("model_unavailable.unknown.title")
        }
    }

    private var message: String {
        switch availability {
        case .appleIntelligenceNotEnabled:
            L10n.format("model_unavailable.not_enabled.message", AppInfo.name)
        case .modelNotReady:
            L10n.string("model_unavailable.not_ready.message")
        case .deviceNotEligible:
            L10n.format("model_unavailable.not_supported.message", AppInfo.name)
        default:
            L10n.format("model_unavailable.unknown.message", AppInfo.name)
        }
    }
}

// MARK: - Previews

#Preview("Device not eligible") {
    ModelUnavailableView(availability: .deviceNotEligible, onRetry: {})
}

#Preview("Not enabled") {
    ModelUnavailableView(availability: .appleIntelligenceNotEnabled, onRetry: {})
}

#Preview("Model not ready") {
    ModelUnavailableView(availability: .modelNotReady, onRetry: {})
}
