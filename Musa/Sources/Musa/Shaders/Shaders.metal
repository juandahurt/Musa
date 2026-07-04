#include <metal_stdlib>

using namespace metal;

struct vertex_input {
    float4 position [[attribute(0)]];
    float2 uv [[attribute(1)]];
};

struct fragment_input {
    float4 position [[position]];
};

vertex fragment_input vertex_shader(vertex_input input [[stage_in]], constant float4x4& model_matrix [[buffer(1)]], constant float4x4& projection_matrix [[buffer(2)]]) {
    return fragment_input {
        .position = projection_matrix * model_matrix * input.position
    };
}

fragment half4 fragment_shader(fragment_input input [[stage_in]]) {
    return half4(1, 1, 1, 1);
}
