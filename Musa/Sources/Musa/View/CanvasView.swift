import Metal
import UIKit

/// A drawable canvas.
///
/// You can add it wherever you want to have a drawable canvas.
///
/// ```swift
/// let canvas = CanvasView()
/// yourView.add(canvas)
/// ```
public class CanvasView: UIView {
    let renderer: Renderer
    
    override public class var layerClass: AnyClass {
        CAMetalLayer.self
    }
    
    var metalLayer: CAMetalLayer {
        layer as! CAMetalLayer
    }

    public init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU not available")
        }
        renderer = Renderer(device: device)
        super.init(frame: .zero)
        
        metalLayer.device = device
        metalLayer.pixelFormat = .rgba8Unorm
        metalLayer.needsDisplayOnBoundsChange = true
       
        renderer.layer = metalLayer
        
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("unreachable code!")
    }
    
    public override func layoutSubviews() {
        // TODO: update the transforms
        // TODO: call set needs display on renderer
    }
}
