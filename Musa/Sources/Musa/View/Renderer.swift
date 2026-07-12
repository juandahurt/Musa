import MetalKit
import QuartzCore

struct Touch {
    var position: CGPoint
}

class Renderer {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue?
    
    var pipeline: MTLRenderPipelineState?
    
    var canvasTexture: MTLTexture?
    let canvasSize: CGSize = .init(width: 250, height: 400)
    var camera: Camera
    
    var layer: CAMetalLayer?
    
    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        self.camera = .init(
            squareSize: Float(
                max(
                    canvasSize.width,
                    canvasSize.height
                )
            )
        )
        load()
    }
    
    func moveCamera(by point: CGPoint) {
        camera.translation.x += point.x
        camera.translation.y += point.y
    }
    
    func zoom(by scale: CGFloat, around screenPoint: CGPoint) {
        guard let layer else { return }

        // to world coordinates
        let fx = CGFloat(camera.center.x) - layer.bounds.width / 2 + screenPoint.x
        let fy = CGFloat(camera.center.y) - layer.bounds.height / 2 + screenPoint.y

        camera.translation.x = scale * camera.translation.x + (1 - scale) * fx
        camera.translation.y = scale * camera.translation.y + (1 - scale) * fy
        camera.scale *= scale
    }
    
    func rotate(by beta: CGFloat, around screenPoint: CGPoint) {
        guard let layer else { return }
        
        // world coordinates
        let fx = CGFloat(camera.center.x) - layer.bounds.width  / 2 + screenPoint.x
        let fy = CGFloat(camera.center.y) - layer.bounds.height / 2 + screenPoint.y
        
        let dx = camera.translation.x - fx
        let dy = camera.translation.y - fy
        
        let c = cos(beta), s = sin(beta)
        camera.translation.x = fx + (c * dx - s * dy)
        camera.translation.y = fy + (s * dx + c * dy)
        
        camera.rotation += beta
    }
    
    func load() {
        let library = try? device.makeDefaultLibrary(bundle: .module)
        let vertex = library?.makeFunction(name: "vertex_shader")
        let fragment = library?.makeFunction(name: "fragment_shader")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float4
        
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[1].format = .float2
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.vertexFunction = vertex
        pipelineDescriptor.fragmentFunction = fragment
        pipelineDescriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
        
        do {
            pipeline = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print(error)
        }
        
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.width = Int(canvasSize.width)
        textureDescriptor.height = Int(canvasSize.height)
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        canvasTexture = device.makeTexture(descriptor: textureDescriptor)
        
        fillCanvasTexture()
        
        setupLoop()
    }
    
    func setupLoop() {
        let link = CADisplayLink(target: self, selector: #selector(step))
        link.add(to: .main, forMode: .common)
    }
    
    @objc
    func step() {
       display()
    }
    
    func fillCanvasTexture() {
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let renderDescriptor = MTLRenderPassDescriptor()
        renderDescriptor.colorAttachments[0].texture = canvasTexture
        renderDescriptor.colorAttachments[0].loadAction = .clear
        renderDescriptor.colorAttachments[0].clearColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderDescriptor)
        encoder?.endEncoding()
        commandBuffer?.commit()
    }
    
    private func display() {
        print("display")
        guard let layer else { return }
        guard let drawable = layer.nextDrawable() else { return }
        guard let pipeline else { return }
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
       
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].clearColor = .init(red: 0.78, green: 0.78, blue: 0.78, alpha: 1)
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store
        
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        
        let cx = camera.center.x, cy = camera.center.y
        let hw = Float(canvasSize.width  / 2)
        let hh = Float(canvasSize.height / 2)
        let vertices: [Vertex] = [
            .init(position: [cx - hw, cy - hh, 0, 1], uv: [0, 0]), // top-left
            .init(position: [cx + hw, cy - hh, 0, 1], uv: [1, 0]), // top-right
            .init(position: [cx - hw, cy + hh, 0, 1], uv: [0, 1]), // bottom-left
            .init(position: [cx + hw, cy + hh, 0, 1], uv: [1, 1]), // bottom-right
        ]
        let vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count)
        encoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        let indices: [UInt16] = [
            0, 1, 2,
            1, 2, 3
        ]
        let indexBuffer = device.makeBuffer(
            bytes: indices,
            length: MemoryLayout<UInt16>.stride * indices.count
        )
        var viewMatrix = camera.viewMatrix
        encoder?.setVertexBytes(
            &viewMatrix,
            length: MemoryLayout<simd_float4x4>.stride,
            index: 1
        )

        let vw = layer.bounds.width, vh = layer.bounds.height
        let c = camera.center
        let rect = CGRect(
            x: CGFloat(c.x) - vw/2,
            y: CGFloat(c.y) - vh/2,
            width: vw,
            height: vh
        )
        var projectionMatrix = float4x4(
            ortho: rect,
            near: 0,
            far: 1
        )
        encoder?.setVertexBytes(
            &projectionMatrix,
            length: MemoryLayout<simd_float4x4>.stride,
            index: 2
        )
        
        encoder?.setFragmentTexture(canvasTexture, index: 0)
        
        encoder?.setRenderPipelineState(pipeline)
        encoder?.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indices.count,
            indexType: .uint16,
            indexBuffer: indexBuffer!,
            indexBufferOffset: 0
        )
        
        encoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

