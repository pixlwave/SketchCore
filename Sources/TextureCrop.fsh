// Attributes:
// float left
// float bottom
// float right
// float top

void main()
{
    // calculate the frame and size of the crop
    vec4 frame = vec4(left, bottom, right, top);
    vec2 frameSize = vec2(1 - (frame.x + frame.z), 1 - (frame.y + frame.w));
    
    // calculate texture coordinate to sample
    vec2 sourceCoord = vec2(v_tex_coord * frameSize + frame.xy);
    
    // sample the coordinate and multiply by the colour
    vec4 color = texture2D(u_texture, sourceCoord);
    gl_FragColor = color * v_color_mix;
}
