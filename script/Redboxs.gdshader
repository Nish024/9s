shader_type spatial;
render_mode unshaded;

void fragment() {
    float scale = 5.0; // controls stripe size
    vec2 uv = UV * scale;

    // Diagonal stripe pattern
    float stripe = step(0.5, fract(uv.x + uv.y));

    // Dark red (deep)
    vec3 dark_red  = pow(vec3(0.60, 0.0, 0.0), vec3(2.2)); // ~#990000
    // Slightly darker light red
    vec3 mid_red   = pow(vec3(0.85, 0.25, 0.25), vec3(2.2)); // ~#D94242

    // Mix based on stripe
    vec3 color = mix(dark_red, mid_red, stripe);

    ALBEDO = color;
}
