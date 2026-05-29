shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float speed : hint_range(0.0, 10.0) = 3.0;
uniform float line_thickness : hint_range(0.0, 0.5) = 0.02;
uniform float inner_glow : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec2 uv = UV - 0.5;
	float dist = length(uv);
	float angle = atan(uv.y, uv.x);
	
	// 1. Efecto de anillo giratorio de energía
	float ring = smoothstep(0.48, 0.48 - line_thickness, dist) * smoothstep(0.4, 0.4 + line_thickness, dist);
	float swirl = sin(angle * 3.0 + TIME * speed) * 0.5 + 0.5;
	
	// 2. Brillo interior sutil
	float glow = smoothstep(0.45, 0.1, dist) * inner_glow * (sin(TIME * 2.0) * 0.1 + 0.9);
	
	// --- SOLUCIÓN AL BORDE NEGRO ---
	// Forzamos el color a ser el line_color (blanco) para evitar que se mezcle con el fondo oscuro del PNG
	// El truco es usar el alpha del texture pero ignorar su RGB si este tiende a negro en los bordes.
	COLOR.rgb = line_color.rgb;
	
	// El alpha final es la suma del alpha del número + el anillo de energía
	float final_alpha = tex_color.a;
	final_alpha = max(final_alpha, ring * line_color.a * swirl);
	
	// Aplicar el brillo interior (glow) sumando al RGB
	COLOR.rgb += line_color.rgb * glow * 0.3;
	COLOR.a = final_alpha;
}
