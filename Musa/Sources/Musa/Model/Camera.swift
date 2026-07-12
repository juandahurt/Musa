import CoreGraphics
import simd

// TODO: update rotation when device is rotated
struct Camera {
    var squareSize: Float
    var translation: CGPoint = .zero
    var scale: CGFloat = 1
    var rotation: CGFloat = 0
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
