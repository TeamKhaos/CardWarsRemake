shader_type canvas_item;

uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_intensity : hint_range(0.0, 1.0) = 0.2;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float pulse = sin(TIME * pulse_speed) * pulse_intensity + (1.0 - pulse_intensity);
	
	// Brillo exterior suave
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);
	float glow = smoothstep(0.5, 0.2, dist) * pulse;
	
	COLOR = tex * COLOR;
	COLOR.rgb += glow * COLOR.rgb * 0.5;
	COLOR.a = tex.a * (0.8 + 0.2 * pulse);
}
