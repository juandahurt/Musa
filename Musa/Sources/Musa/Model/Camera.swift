import CoreGraphics
import simd

// TODO: update rotation when device is rotated
struct Camera {
    var squareSize: Float
    var translation: CGPoint = .zero
    var scale: CGFloat = 1
    var rotation: CGFloat = 0
    
    mutating func translate(by point: CGPoint) {
        translation.x += point.x
        translation.y += point.y
    }
    
    mutating func zoom(by scale: CGFloat, around screenPoint: CGPoint, in bounds: CGRect) {
        // to world coordinates
        let fx = CGFloat(center.x) - bounds.width / 2 + screenPoint.x
        let fy = CGFloat(center.y) - bounds.height / 2 + screenPoint.y

        translation.x = scale * translation.x + (1 - scale) * fx
        translation.y = scale * translation.y + (1 - scale) * fy
        self.scale *= scale
    }
    
    mutating func rotate(by beta: CGFloat, around screenPoint: CGPoint, in bounds: CGRect) {
        // world coordinates
        let fx = CGFloat(center.x) - bounds.width  / 2 + screenPoint.x
        let fy = CGFloat(center.y) - bounds.height / 2 + screenPoint.y
        
        let dx = translation.x - fx
        let dy = translation.y - fy
        
        let c = cos(beta), s = sin(beta)
        translation.x = fx + (c * dx - s * dy)
        translation.y = fy + (s * dx + c * dy)
        rotation += beta
    }
}


extension Camera {
    var center: SIMD2<Float> {
        [squareSize / 2, squareSize / 2]
    }
    
    var viewMatrix: simd_float4x4 {
        CGAffineTransform.identity
            .translatedBy(x: translation.x, y: translation.y)
            .rotated(by: rotation)
            .scaledBy(x: scale, y: scale)
            .simd
    }
}
