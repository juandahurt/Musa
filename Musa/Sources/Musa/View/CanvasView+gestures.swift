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
    }
    
    // MARK: Translation
    @objc
    func onPan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: self)
        renderer.moveCamera(by: translation)
        panGestureRecognizer.setTranslation(.zero, in: self)
    }
    
    // MARK: Zoom
    @objc
    func onPinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        let location = pinchGestureRecognizer.location(in: self)
        renderer.zoom(by: pinchGestureRecognizer.scale, around: location)
        pinchGestureRecognizer.scale = 1
    }
}


extension CanvasView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
