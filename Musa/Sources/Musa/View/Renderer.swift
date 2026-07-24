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
    var layer: CAMetalLayer?
    
    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        load()
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
//        textureDescriptor.width = Int(state.canvasSize.width)
//        textureDescriptor.height = Int(state.canvasSize.height)
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        canvasTexture = device.makeTexture(descriptor: textureDescriptor)
    }
    
    // TODO: add commands
    func execute(passes: [RenderPass], in layer: CAMetalLayer) {
        print("display")
        guard let drawable = layer.nextDrawable() else { return }
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else { return }
        
        for pass in passes {
            // TODO: we need to have a pipeline per render pass
            guard let pipeline else { return }
            
            let descriptor = MTLRenderPassDescriptor()
            if let clearColor = pass.clearColor {
                descriptor.colorAttachments[0].clearColor = clearColor.mtlClearColor
            }
            if case .texture = pass.target {
                descriptor.colorAttachments[0].texture = canvasTexture
            }
            if case .screen = pass.target {
                descriptor.colorAttachments[0].texture = drawable.texture
            }
            descriptor.colorAttachments[0].loadAction = .clear
            descriptor.colorAttachments[0].storeAction = .store
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            // TODO: find a better way to check if we need to pass fragment textures, maybe another command?
            encoder?.setFragmentTexture(canvasTexture, index: 0)
            // TODO: probaly we need a pipeline per pass
            encoder?.setRenderPipelineState(pipeline)
            for command in pass.commands {
                switch command {
                case .setViewMatrix(var viewMatrix):
                    encoder?.setVertexBytes(
                        &viewMatrix,
                        length: MemoryLayout<simd_float4x4>.stride,
                        index: 1
                    )
                case .setProjectionMatrix(var projectionMatrix):
                    encoder?.setVertexBytes(
                        &projectionMatrix,
                        length: MemoryLayout<simd_float4x4>.stride,
                        index: 2
                    )
                case .drawQuad(vertices: let vertices, indices: let indices):
                    let vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count)
                    encoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                    let indexBuffer = device.makeBuffer(
                        bytes: indices,
                        length: MemoryLayout<UInt16>.stride * indices.count
                    )
                    encoder?.drawIndexedPrimitives(
                        type: .triangle,
                        indexCount: indices.count,
                        indexType: .uint16,
                        indexBuffer: indexBuffer!,
                        indexBufferOffset: 0
                    )
                }
            }
            encoder?.endEncoding()
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

