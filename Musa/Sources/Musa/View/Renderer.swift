import MetalKit
import QuartzCore

class Renderer: NSObject, CALayerDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue?
    
    var pipeline: MTLRenderPipelineState?
    
    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        super.init()
        load()
    }
    
    func load() {
        let library = try? device.makeDefaultLibrary(bundle: .module)
        let vertex = library?.makeFunction(name: "vertex_shader")
        let fragment = library?.makeFunction(name: "fragment_shader")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD4<Float>>.stride
        
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
    }
    
    func display(_ layer: CALayer) {
        guard let metalLayer = layer as? CAMetalLayer else { return }
        guard let drawable = metalLayer.nextDrawable() else { return }
        guard let pipeline else { return }
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
       
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].clearColor = .init(red: 0.2, green: 0.3, blue: 0.5, alpha: 1)
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].loadAction = .clear
        
        let vertices: [SIMD4<Float>] = [
            [-1, -1, 0, 1],
             [0, -1, 0, 1],
             [0,  0, 0, 1]
        ]
        let vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<SIMD4<Float>>.stride * vertices.count
        )
        
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        encoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder?.setRenderPipelineState(pipeline)
        encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        encoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

