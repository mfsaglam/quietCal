import Foundation
import FoundationModels

/// Maps the live `SystemLanguageModel` availability into ``ModelAvailability``.
/// Reading `availability` re-queries the system each time, so a value can move
/// from unavailable to available once the user enables Apple Intelligence or
/// the model finishes downloading.
struct SystemModelAvailabilityProvider: ModelAvailabilityProviding {
    var availability: ModelAvailability {
        switch SystemLanguageModel.default.availability {
        case .available:
            return .available
        case .unavailable(.deviceNotEligible):
            return .deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            return .appleIntelligenceNotEnabled
        case .unavailable(.modelNotReady):
            return .modelNotReady
        case .unavailable:
            return .unknown
        }
    }
}
