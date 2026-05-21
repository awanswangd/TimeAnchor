shader_type canvas_item;

uniform vec4 ghost_color : source_color = vec4(0.0, 0.8, 1.0, 1.0); 
uniform float glow_intensity : hint_range(1.0, 5.0) = 1.5; 
uniform float flicker_speed : hint_range(0.0, 10.0) = 1.0; 

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	
	if (original_color.a < 0.1) {
		discard;
	}
	
	float flicker = abs(sin(TIME * flicker_speed));
	flicker = clamp(flicker, 0.3, 1.0); 
	
	vec3 new_color = mix(original_color.rgb, ghost_color.rgb, 0.9);
	
	COLOR.rgb = new_color * glow_intensity;
	COLOR.a = original_color.a * 0.7 * flicker; 
}