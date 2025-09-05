shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled;

uniform vec3 flat_color : source_color = vec3(1.0, 0.5, 0.0); // orange
uniform float alpha_strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // Use ALBEDO directly since unshaded ignores lights
    ALBEDO = flat_color;
    ALPHA = alpha_strength;
}
