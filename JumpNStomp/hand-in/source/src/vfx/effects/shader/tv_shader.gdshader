shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest; // read the sceen behind

// ---- effect toggles ----
uniform bool lower_definition_on = true;
uniform bool glow_on = true;
uniform bool scanlines_on = true;
uniform bool vignette_on = true;

// ---- settings ----
uniform float pixel_size = 1;
uniform float line_count = 1200.0;
uniform float line_speed = 0.2;

uniform float darkest_line = 0.6;
uniform float brightest_line = 1.0;

uniform float glow_size = 2.0;
uniform float glow_strength = 0.40;

uniform float vignette_strength = 0.4;
uniform float vignette_size = 0.85;


void fragment() {
	// ---- lower definition ----
	vec2 pixel_uv = SCREEN_UV; // starts as normal screen uv

	if (lower_definition_on) {
		pixel_uv = floor(SCREEN_UV / SCREEN_PIXEL_SIZE / pixel_size) * SCREEN_PIXEL_SIZE * pixel_size;
	}

	vec4 screen_color = texture(screen_texture, pixel_uv);

	// ---- scanlines ----
	if (scanlines_on) {
		float line = sin((UV.y - TIME * line_speed) * line_count);
		line = line * 0.5 + 0.5;

		float brightness = mix(darkest_line, brightest_line, line);

		screen_color.rgb *= brightness;
	
	// ---- glow ----
	if (glow_on) {
		vec2 glow_offset = SCREEN_PIXEL_SIZE * glow_size; // distance to neighbor pixels

		vec4 glow_color = vec4(0.0); // starts empty, otherwise white screen

		glow_color += texture(screen_texture, pixel_uv + vec2(glow_offset.x, 0.0)); // right
		glow_color += texture(screen_texture, pixel_uv - vec2(glow_offset.x, 0.0)); // left
		glow_color += texture(screen_texture, pixel_uv + vec2(0.0, glow_offset.y)); // down
		glow_color += texture(screen_texture, pixel_uv - vec2(0.0, glow_offset.y)); // up

		glow_color = glow_color / 4.0; // average the 4 neighbor colors

		screen_color.rgb += glow_color.rgb * glow_strength; // add glow to original screen color
	}

	
	// ---- vignette ----
if (vignette_on) {
	float distance_from_center = distance(UV, vec2(0.5, 0.5)); // 0 in center, bigger near corners

	float vignette = smoothstep(vignette_size, vignette_size - vignette_strength, distance_from_center);

	screen_color.rgb *= vignette;
}
	}
	
	

	// ---- final color ----
	COLOR = screen_color;
}