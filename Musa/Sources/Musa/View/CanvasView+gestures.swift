import UIKit

extension CanvasView {
    func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(onPinch(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(onRotation(_:)))
        rotationGesture.delegate = self
        addGestureRecognizer(rotationGesture)
    }
    
    // MARK: Translation
    @objc
    func onPan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard FeatureFlagsManager.shared.isEnabled(.cameraMovement) else { return }
        
        let translation = panGestureRecognizer.translation(in: self)
        renderer.moveCamera(by: translation)
        panGestureRecognizer.setTranslation(.zero, in: self)
    }
    
    // MARK: Zoom
    @objc
    func onPinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        guard FeatureFlagsManager.shared.isEnabled(.cameraMovement) else { return }
        
        let location = pinchGestureRecognizer.location(in: self)
        renderer.zoom(by: pinchGestureRecognizer.scale, around: location)
        pinchGestureRecognizer.scale = 1
    }
    
    // MARK: Rotation
    @objc
    func onRotation(_ rotationGestureRecognizer: UIRotationGestureRecognizer) {
        guard FeatureFlagsManager.shared.isEnabled(.cameraMovement) else { return }
        
        let location = rotationGestureRecognizer.location(in: self)
        renderer.rotate(by: rotationGestureRecognizer.rotation, around: location)
        rotationGestureRecognizer.rotation = 0
    }
}


extension CanvasView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
