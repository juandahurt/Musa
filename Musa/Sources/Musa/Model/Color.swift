import Metal

struct Color {
    var r, g, b, a: Double
    
    var mtlClearColor: MTLClearColor {
        .init(red: r, green: g, blue: b, alpha: a)
    }
}


extension Color {
    static let white = Color(r: 1, g: 1, b: 1, a: 1)
}
