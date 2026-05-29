shader_type canvas_item;

uniform vec4 aura_color : source_color = vec4(0.0, 0.5, 1.0, 0.6);
uniform float aura_width : hint_range(0.0, 0.1) = 0.03;
uniform float speed : hint_range(0.0, 5.0) = 2.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	// Crear un borde exterior suave
	float dist_x = min(UV.x, 1.0 - UV.x);
	float dist_y = min(UV.y, 1.0 - UV.y);
	float edge = 1.0 - smoothstep(0.0, aura_width, min(dist_x, dist_y));
	
	// Animación de pulso/onda
	float pulse = sin(TIME * speed) * 0.5 + 0.5;
	float wave = sin(UV.y * 10.0 + TIME * speed * 2.0) * 0.1;
	
	vec3 aura = aura_color.rgb * (edge + wave) * intensity * pulse;
	
	// Combinar el color original con el aura en los bordes
	COLOR.rgb = mix(color.rgb, aura, edge * aura_color.a);
	COLOR.a = color.a;
	
	// Añadir un brillo general suave
	COLOR.rgb += aura * 0.2;
}
