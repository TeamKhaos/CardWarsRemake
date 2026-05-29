shader_type canvas_item;

uniform vec4 text_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float shine_speed : hint_range(0.0, 10.0) = 2.0;
uniform float shine_width : hint_range(0.0, 1.0) = 0.2;
uniform float glow_amount : hint_range(0.0, 5.0) = 1.5;

void fragment() {
    // Tomamos el color y alpha original del texto
    vec4 color = texture(TEXTURE, UV);
    
    // Crear un barrido de luz (shine) sutil
    float shine = step(1.0 - shine_width, 0.5 + 0.5 * sin(UV.x - UV.y + TIME * shine_speed));
    
    // Aplicar el color base y el brillo
    vec3 final_rgb = mix(text_color.rgb, vec3(1.0), shine * 0.5);
    
    // Añadir un brillo (glow) constante para que resalte
    final_rgb *= glow_amount;
    
    COLOR = vec4(final_rgb, color.a * text_color.a);
}
