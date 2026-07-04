public enum FeatureFlag: String, CaseIterable {
    case test = "Test Flag"
}

public class FeatureFlagsManager {
    nonisolated(unsafe)
    public static let shared = FeatureFlagsManager()
    
    var features: [FeatureFlag: Bool] = [:]
    
    init() {
        set(.test, value: false)
    }
    
    public func set(_ featureFlag: FeatureFlag, value: Bool) {
        features[featureFlag] = value
    }
    
    public func isEnabled(_ featureFlag: FeatureFlag) -> Bool {
        features[featureFlag] ?? false
    }
}
