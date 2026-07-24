import Metal
import simd

enum RenderCommand {
    case setViewMatrix(simd_float4x4)
    case setProjectionMatrix(simd_float4x4)
    case drawQuad(vertices: [Vertex], indices: [UInt16])
}
