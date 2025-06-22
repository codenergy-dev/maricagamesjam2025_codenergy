shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;
uniform sampler2D noise_texture: filter_nearest, repeat_enable;

void fragment() {
	float distortion = 0.005;
	float wave_strength = 0.1;
	vec2 speed = vec2(0.5, 0.2);
	vec4 water_color = vec4(0.3, 0.8, 0.9, 0.3);

	vec2 noise = 2.0 * texture(noise_texture, UV + speed * TIME).rg - vec2(1.0);
	vec4 refraction = texture(screen_texture, SCREEN_UV + noise * distortion);

	vec4 color = vec4(1.0);
	color.rgb = mix(refraction.rgb, water_color.rgb, water_color.a);
	COLOR = color;
}