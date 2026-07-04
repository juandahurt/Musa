#include <metal_stdlib>
#include "Types.h"

using namespace metal;

struct fragment_input {
    float4 position [[position]];
    float2 uv;
};

vertex fragment_input vertex_shader(vertex_input input [[stage_in]], constant float4x4& model_matrix [[buffer(1)]], constant float4x4& projection_matrix [[buffer(2)]]) {
    return fragment_input {
        .position = projection_matrix * model_matrix * input.position
    };
}

fragment float4 fragment_shader(fragment_input input [[stage_in]], texture2d<float, access::sample> canvas_texture       [[texture(0)]]) {
    constexpr sampler canvas_sampler(coord::normalized, address::clamp_to_edge, filter::linear);
    float4 color = canvas_texture.sample(canvas_sampler, input.uv);
    return color;
}
