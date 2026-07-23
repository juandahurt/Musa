struct RenderPass {
    var target: RenderTarget
    var commands: [RenderCommand]
}

enum RenderTarget {
    case screen
}
