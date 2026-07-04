import CoreGraphics
import simd

extension simd_float4x4 {
    init(ortho rect: CGRect, near: CGFloat, far: CGFloat) {
        let left = rect.minX
        let right = rect.minX + rect.width
        let top = rect.minY
        let bottom = rect.minY + rect.height
        let X = simd_float4(2 / Float((right - left)), 0, 0, 0)
        let Y = simd_float4(0, 2 / Float((top - bottom)), 0, 0)
        let Z = simd_float4(0, 0, 1 / Float((far - near)), 0)
        let W = simd_float4(
            Float((left + right) / (left - right)),
            Float((top + bottom) / (bottom - top)),
            Float(near / (near - far)),
            1)
        self.init(columns: (X, Y, Z, W))
    }
}
