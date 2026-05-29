shader_type canvas_item;

uniform vec4 rim_color : source_color = vec4(1.0, 1.0, 1.0, 0.4);
uniform float rim_width : hint_range(0.0, 0.5) = 0.15;
uniform float pulse_speed : hint_range(0.0, 5.0) = 0.5;
uniform float pulse_intensity : hint_range(0.0, 0.1) = 0.03;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.2;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	// 1. Efecto de Viñeta interna para dar profundidad
	float dist_center = distance(UV, vec2(0.5));
	float vignette = smoothstep(0.3, 0.6, dist_center) * vignette_intensity;
	
	// 2. Rim Light (Brillo en los bordes)
	// Usamos los bordes de la textura (UV)
	float rim_x = smoothstep(0.0, rim_width, UV.x) * smoothstep(1.0, 1.0 - rim_width, UV.x);
	float rim_y = smoothstep(0.0, rim_width, UV.y) * smoothstep(1.0, 1.0 - rim_width, UV.y);
	float rim = 1.0 - (rim_x * rim_y);
	
	// 3. Pulso de "respiración" muy sutil
	float pulse = sin(TIME * pulse_speed) * pulse_intensity;
	
	// Combinación
	vec3 final_color = color.rgb;
	final_color = mix(final_color, rim_color.rgb, rim * rim_color.a); // Aplicar borde
	final_color -= vignette; // Oscurecer centro ligeramente
	final_color += pulse;    // Añadir pulso general
	
	COLOR = vec4(final_color, color.a);
}
