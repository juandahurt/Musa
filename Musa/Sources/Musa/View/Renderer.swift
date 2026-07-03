import MetalKit
import QuartzCore

struct Touch {
    var position: CGPoint
}

class Renderer {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue?
    
    var pipeline: MTLRenderPipelineState?
   
    var touches: [Touch] = []
    
    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        load()
    }
    
    func pushTouch(_ touch: Touch) {
        touches.append(touch)
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
    
    func display(_ layer: CAMetalLayer) {
        print("display")
        guard let drawable = layer.nextDrawable() else { return }
        guard let pipeline else { return }
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
       
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].clearColor = .init(red: 0.2, green: 0.3, blue: 0.5, alpha: 1)
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store
        
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        
        let indices: [UInt16] = [
            0, 1, 2,
            0, 2, 3
        ]
        let indexBuffer = device.makeBuffer(
            bytes: indices,
            length: MemoryLayout<Float16>.stride * indices.count
        )
        
        for touch in touches {
            let vertices: [SIMD4<Float>] = [
                [1,  1, 0, 1],
                [1, -1, 0, 1],
                [-1, -1, 0, 1],
                [-1,  1, 0, 1],
            ]
            let vertexBuffer = device.makeBuffer(
                bytes: vertices,
                length: MemoryLayout<SIMD4<Float>>.stride * vertices.count
            )
            encoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            
            var modelMatrix = CGAffineTransform
                .identity
                .translatedBy(x: touch.position.x, y: touch.position.y)
                .scaledBy(x: 4, y: 4)
                .simd
            encoder?.setVertexBytes(
                &modelMatrix,
                length: MemoryLayout<simd_float4x4>.stride,
                index: 1
            )
            
            let rect = CGRect(
                x: 0,
                y: 0,
                width: layer.bounds.width,
                height: layer.bounds.height
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
            
            encoder?.setRenderPipelineState(pipeline)
            encoder?.drawIndexedPrimitives(
                type: .triangle,
                indexCount: indices.count,
                indexType: .uint16,
                indexBuffer: indexBuffer!,
                indexBufferOffset: 0
            )
        }
        
        encoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

