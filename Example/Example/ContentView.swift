import Musa
import SwiftUI

struct ContentView: View {
    @State private var flagsManager: FeatureFlagsWrapper = .init()

    var body: some View {
        CanvasWrapper()
//            .frame(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.height)
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                DebugPanel(title: "Feature Flags") {
                    ForEach(FeatureFlag.allCases, id: \.self) { flag in
                        DebugToggle(label: flag.rawValue, value: .init(
                            get: { flagsManager.isEnabled(flag) },
                            set: { flagsManager.set(flag, value: $0) }
                        ))
                    }
                }
                .padding()
            }
    }
}

@Observable
class FeatureFlagsWrapper {
    private let manager = FeatureFlagsManager.shared
    private var states: [FeatureFlag: Bool]

    init() {
        let manager = FeatureFlagsManager.shared
        states = Dictionary(uniqueKeysWithValues: FeatureFlag.allCases.map { ($0, manager.isEnabled($0)) })
    }

    func isEnabled(_ flag: FeatureFlag) -> Bool {
        states[flag] ?? false
    }

    func set(_ flag: FeatureFlag, value: Bool) {
        manager.set(flag, value: value)
        states[flag] = value
    }
}

struct CanvasWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        CanvasView()
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}

#Preview {
    ContentView()
}
