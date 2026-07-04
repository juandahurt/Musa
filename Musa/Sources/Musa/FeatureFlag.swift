public enum FeatureFlag: String, CaseIterable {
    case coalescedTouches = "Use coealesced touches"
}

public class FeatureFlagsManager {
    nonisolated(unsafe)
    public static let shared = FeatureFlagsManager()
    
    var features: [FeatureFlag: Bool] = [:]
    
    init() {
        set(.coalescedTouches, value: false)
    }
    
    public func set(_ featureFlag: FeatureFlag, value: Bool) {
        features[featureFlag] = value
    }
    
    public func isEnabled(_ featureFlag: FeatureFlag) -> Bool {
        features[featureFlag] ?? false
    }
}
