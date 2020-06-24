#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4 position [[ position ]];
    float2 textureCoordinate;
} TexturedQuadVertex;

vertex TexturedQuadVertex mapTexture(unsigned int vertex_id [[ vertex_id ]]) {
    float4x4 quadPositions = float4x4(float4( -1.0, -1.0, 0.0, 1.0 ),      /// (x, y, depth, W)
                                      float4(  1.0, -1.0, 0.0, 1.0 ),
                                      float4( -1.0,  1.0, 0.0, 1.0 ),
                                      float4(  1.0,  1.0, 0.0, 1.0 ));
    
    float4x2 textureCoordinates = float4x2(float2( 0.0, 1.0 ), /// (x, y)
                                           float2( 1.0, 1.0 ),
                                           float2( 0.0, 0.0 ),
                                           float2( 1.0, 0.0 ));
    TexturedQuadVertex outVertex;
    outVertex.position = quadPositions[vertex_id];
    outVertex.textureCoordinate = textureCoordinates[vertex_id];
    
    return outVertex;
}

fragment half4 displayTexture(TexturedQuadVertex texturedQuadVertex [[ stage_in ]], texture2d<float, access::sample> texture [[ texture(0) ]]) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    
    return half4(texture.sample(s, texturedQuadVertex.textureCoordinate));
}

struct QuadVertex {
    float4 position [[ position ]];
};

vertex QuadVertex vertexSimpleQuad(uint vertex_id [[ vertex_id ]]) {
    float4x4 quadPositions = float4x4(float4( -1.0, -1.0, 0.0, 1.0 ),      /// (x, y, depth, W)
                                      float4(  1.0, -1.0, 0.0, 1.0 ),
                                      float4( -1.0,  1.0, 0.0, 1.0 ),
                                      float4(  1.0,  1.0, 0.0, 1.0 ));
    QuadVertex outVertex;
    outVertex.position = quadPositions[vertex_id];
    return outVertex;
}

fragment float4 displayColor(constant float4 &color [[ buffer(0) ]]) {
    return color;
}
