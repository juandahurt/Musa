import CoreGraphics

struct CanvasState {
    let canvasSize: CGSize = .init(width: 250, height: 400)
    var camera: Camera
    var touches: [Touch] = []
    
    init() {
        self.camera = .init(
            squareSize: Float(
                max(
                    canvasSize.width,
                    canvasSize.height
                )
            )
        )
    }
}
