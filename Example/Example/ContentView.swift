import Musa
import SwiftUI

struct ContentView: View {
    var body: some View {
        CanvasWrapper()
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
