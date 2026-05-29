shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.4;
uniform float nebula_speed : hint_range(0.0, 2.0) = 0.1;
uniform float nebula_opacity : hint_range(0.0, 1.0) = 0.15;

// Función de ruido simple para las nubes/nebulosa
float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec2 centered_uv = UV - 0.5;
    
    // 1. Viñeta (Oscurecer bordes para centrar la atención)
    float dist = length(centered_uv);
    float vignette = smoothstep(0.3, 0.7, dist) * vignette_intensity;
    
    // 2. Nebulosa / Niebla sutil en movimiento
    // Usamos ondas senoidales para simular nubes de energía
    float cloud = sin(UV.x * 3.0 + TIME * nebula_speed) * cos(UV.y * 2.0 - TIME * nebula_speed * 0.5);
    cloud += sin(UV.y * 4.0 + TIME * nebula_speed * 0.8) * cos(UV.x * 1.5 + TIME * nebula_speed);
    
    // 3. Mezcla final
    vec3 final_rgb = tex.rgb * base_color.rgb;
    
    // Añadimos la "niebla" de luz
    final_rgb += vec3(1.0) * cloud * nebula_opacity;
    
    // Aplicamos la viñeta (restamos luz en los bordes)
    final_rgb -= vignette;
    
    COLOR = vec4(final_rgb, tex.a);
}
