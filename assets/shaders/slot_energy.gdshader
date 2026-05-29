shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_thickness : hint_range(0.0, 10.0) = 2.0;
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float is_occupied : hint_range(0.0, 1.0) = 0.0; // 0 para vacía, 1 para ocupada

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec2 size = TEXTURE_PIXEL_SIZE;
	
	// 1. Crear un Outline estático
	float outline = 0.0;
	outline += texture(TEXTURE, UV + vec2(size.x * line_thickness, 0)).a;
	outline += texture(TEXTURE, UV - vec2(size.x * line_thickness, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y * line_thickness)).a;
	outline += texture(TEXTURE, UV - vec2(0, size.y * line_thickness)).a;
	outline = step(0.01, outline) - color.a;
	
	// 2. Color final: Blanco brillante estático
	// Multiplicamos el RGB por glow_intensity para que resalte más
	vec3 glow_color = line_color.rgb * glow_intensity;
	
	// 3. Aplicar visibilidad basada en si está ocupada
	// Si is_occupied es 1.0, la visibilidad del brillo es 0
	float visibility = 1.0 - is_occupied;
	
	vec3 final_rgb = mix(color.rgb, glow_color, outline * visibility);
	
	// El alpha de la ranura base es bajo (semi-transparente)
	// El alpha del brillo es fuerte pero solo si no está ocupada
	float final_a = max(color.a * 0.2, outline * line_color.a * visibility);
	
	COLOR = vec4(final_rgb, final_a);
}
