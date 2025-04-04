#pragma header

// Shadow properties
uniform float alpha;  // Shadow transparency (0.0-1.0)
uniform float offsetX; // X offset in pixels
uniform float offsetY; // Y offset in pixels

void main() {
    // Get original pixel color
    vec2 uv = openfl_TextureCoordv.xy;
    vec4 color = flixel_texture2D(bitmap, uv);
    
    // Calculate shadow position (convert pixel offset to UV space)
    vec2 shadowUV = uv - vec2(offsetX, offsetY) / openfl_TextureSize.xy;
    vec4 shadow = flixel_texture2D(bitmap, shadowUV);
    
    // Make shadow black and apply transparency
    shadow.rgb = vec3(0.0);
    shadow.a *= alpha;
    
    // Composite: original over shadow
    gl_FragColor = color + shadow * (1.0 - color.a);
}