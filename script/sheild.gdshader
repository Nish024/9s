shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled;

uniform float stripe_speed : hint_range(-5.0, 5.0) = 1.0;
uniform float stripe_count : hint_range(1.0, 50.0) = 10.0;
uniform vec3 shield_color : source_color = vec3(0.9, 0.9, 0.85);
uniform float alpha_strength : hint_range(0.0, 1.0) = 0.7;
uniform float flash_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec3 flash_color : source_color = vec3(1.0, 0.0, 0.0);

void fragment() {
    float offset = TIME * stripe_speed;
    float stripes = step(0.5, fract(UV.y * stripe_count + offset));

    // Base stripes (beige color or transparent)
    vec3 base_col = mix(vec3(0.0), shield_color, stripes);

    // Blend with flash color
    vec3 final_col = mix(base_col, flash_color, flash_strength);

    ALBEDO = final_col;
    EMISSION = final_col;
    ALPHA = stripes * alpha_strength;
}
