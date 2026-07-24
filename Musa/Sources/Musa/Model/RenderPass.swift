import Metal

struct RenderPass {
    var target: RenderTarget
    var clearColor: Color?
    var commands: [RenderCommand]
}

enum RenderTarget {
    case screen
    case texture // TODO: add textureId
}
