shader_type canvas_item;

uniform vec4 main_color: source_color;
uniform vec4 secondary_color: source_color;

uniform float energy;
uniform float amplitude = 0.07;
uniform float frequency = 4.4;
uniform float waves_diff = 1.2;
uniform float energy_strength = 5.0;

float energy_wave(vec2 uv, float wave_diff){
	float wave = (energy - wave_diff + 1.0) + cos(uv.x * frequency + TIME * wave_diff * energy_strength)
	* amplitude * min(energy * wave_diff * energy_strength, 1.0) * sin( TIME * wave_diff );
	//wave *= step(0.01, energy);
	return step( uv.y, wave );
}

void fragment() {
	vec2 uv = UV;
	uv.y = 1.0 - uv.y;
	float wave_1 = energy_wave(vec2(-uv.x, uv.y) , 1.0);
	float wave_2 = energy_wave(uv, waves_diff);

	vec4 tex = texture( TEXTURE, uv );

	float area_2 = step(1.0 - wave_2, wave_2);
	float area_1 = 1.0 - wave_2;

	COLOR.rgb = area_1 * main_color.rgb + area_2 * secondary_color.rgb;

	float alpha = step( uv.y, wave_1 + wave_2);
	COLOR.a = alpha * tex.a;
}
