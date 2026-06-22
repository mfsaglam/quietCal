import Foundation

/// Whether the on-device model that powers calorie estimation can be used, and
/// when it can't, the reason why. Mirrors `SystemLanguageModel.Availability`
/// but stays free of any `FoundationModels` import so it can be used in the
/// simulator, previews, and tests.
enum ModelAvailability: Equatable {
    case available
    /// The device hardware does not support Apple Intelligence. Permanent.
    case deviceNotEligible
    /// Apple Intelligence is turned off in Settings. Recoverable by the user.
    case appleIntelligenceNotEnabled
    /// The model is downloading or otherwise not yet ready. Transient.
    case modelNotReady
    /// Unavailable for an unknown reason.
    case unknown

    var isAvailable: Bool { self == .available }
}

/// Reports whether the calorie-estimation model is usable on this device.
protocol ModelAvailabilityProviding: Sendable {
    var availability: ModelAvailability { get }
}

/// Always reports the model as available. Used in the simulator, previews, and
/// tests where the real `FoundationModels` model isn't exercised.
struct AlwaysAvailableModelProvider: ModelAvailabilityProviding {
    var availability: ModelAvailability { .available }
}
