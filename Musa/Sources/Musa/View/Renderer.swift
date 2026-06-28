import QuartzCore

class Renderer: NSObject, CALayerDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue?
    
    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()
    }
    
    func display(_ layer: CALayer) {
        guard let metalLayer = layer as? CAMetalLayer else { return }
        guard let drawable = metalLayer.nextDrawable() else { return }
        let commandBuffer = commandQueue?.makeCommandBuffer()
       
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].clearColor = .init(red: 0.2, green: 0.3, blue: 0.5, alpha: 1)
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].loadAction = .clear
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        encoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
