import UIKit

extension CanvasView {
    func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        addGestureRecognizer(panGesture)
    }
    
    // MARK: Translation
    @objc
    func onPan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: self)
        renderer.moveCamera(by: translation)
        panGestureRecognizer.setTranslation(.zero, in: self)
    }
}
