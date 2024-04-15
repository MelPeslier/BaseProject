shader_type canvas_item;
render_mode blend_add;

uniform vec4 color: source_color;
uniform vec4 margin: source_color = vec4(1);

void fragment() {

	COLOR.r = mix(COLOR.r, color.r, step(color.r - margin.r, COLOR.r) );
	COLOR.g = mix(COLOR.g, color.g, step(color.g - margin.g, COLOR.g) );
	COLOR.b = mix(COLOR.b, color.b, step(color.b - margin.b, COLOR.b) );
}