import CoreGraphics
import simd

struct CanvasState {
    let viewSize: CGSize
    let canvasSize: CGSize = .init(width: 250, height: 250)
    var camera: Camera
    var touches: [Touch] = []
    
    /// This just indicates if we have filled the canvas texture
    /// with a white solid color
    var hasLoadedTheCanvasTexture = false
    
    init(viewSize: CGSize) {
        self.viewSize = viewSize
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


extension CanvasState {
    var renderPasses: [RenderPass] {
        var passes: [RenderPass] = []
        if !hasLoadedTheCanvasTexture {
            passes.append(
                .init(
                    target: .texture,
                    clearColor: .white,
                    commands: []
                )
            )
        }
        
        // canvas draw params
        let cx = camera.center.x, cy = camera.center.y
        let hw = Float(canvasSize.width / 2)
        let hh = Float(canvasSize.height / 2)
        let vertices: [Vertex] = [
            .init(position: [cx - hw, cy - hh, 0, 1], uv: [0, 0]), // top-left
            .init(position: [cx + hw, cy - hh, 0, 1], uv: [1, 0]), // top-right
            .init(position: [cx - hw, cy + hh, 0, 1], uv: [0, 1]), // bottom-left
            .init(position: [cx + hw, cy + hh, 0, 1], uv: [1, 1]), // bottom-right
        ]
        let indices: [UInt16] = [
            0, 1, 2,
            1, 2, 3
        ]
        let vw = viewSize.width, vh = viewSize.height
        let c = camera.center
        let rect = CGRect(
            x: CGFloat(c.x) - vw/2,
            y: CGFloat(c.y) - vh/2,
            width: vw,
            height: vh
        )
        let projectionMatrix = float4x4(
            ortho: rect,
            near: 0,
            far: 1
        )
        let canvasDrawPass = RenderPass(
            target: .screen,
            clearColor: .init(r: 0.78, g: 0.78, b: 0.78, a: 1),
            commands: [
                .setViewMatrix(camera.viewMatrix),
                .setProjectionMatrix(projectionMatrix),
                .drawQuad(vertices: vertices, indices: indices)
            ]
        )
        passes.append(canvasDrawPass)
        
        return passes
    }
}
