import CoreGraphics
import simd

// TODO: add rotation when device is rotated
struct Camera {
    var squareSize: Float
    var translation: CGPoint = .zero
}


extension Camera {
    var center: SIMD2<Float> {
        [squareSize / 2, squareSize / 2]
    }
    
    var viewMatrix: simd_float4x4 {
        CGAffineTransform.identity
            .translatedBy(x: translation.x, y: translation.y)
            .simd
    }
}
