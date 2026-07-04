import simd

// TODO: add rotation when device is rotated
struct Camera {
    var squareSize: Float
}


extension Camera {
    var center: SIMD2<Float> {
        [squareSize / 2, squareSize / 2]
    }
    
    var viewMatrix: simd_float4x4 {
        matrix_identity_float4x4
    }
}
