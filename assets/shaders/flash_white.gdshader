shader_type canvas_item;

uniform float flash_strength = 0;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0), flash_strength);
}
