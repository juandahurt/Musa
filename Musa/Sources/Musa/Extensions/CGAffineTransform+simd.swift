import CoreGraphics
import simd

extension CGAffineTransform {
    var simd: float4x4 {
        var matrix = float4x4(1)
        matrix.columns.0.x = Float(a)
        matrix.columns.0.y = Float(b)
        matrix.columns.1.x = Float(c)
        matrix.columns.1.y = Float(d)
        matrix.columns.3.x = Float(tx)
        matrix.columns.3.y = Float(ty)
        return matrix
    }
}
