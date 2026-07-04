import UIKit

extension CanvasView {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        renderer.pushTouch(.init(position: location))
        renderer.display(metalLayer)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        renderer.pushTouch(.init(position: location))
        renderer.display(metalLayer)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        renderer.touches = []
    }
    
    public override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        // TODO: implement re-rendering after updating the current stroke
    }
}
