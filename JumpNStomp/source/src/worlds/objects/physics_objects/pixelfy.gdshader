shader_type canvas_item;

// ---- effect toggles ----
uniform bool lower_definition_on = true;
uniform float pixel_size = 4;

void fragment() {
	vec2 pixel_uv = SCREEN_UV; // starts as normal screen uv

	if (lower_definition_on) {
		pixel_uv = floor(SCREEN_UV / SCREEN_PIXEL_SIZE / pixel_size) * SCREEN_PIXEL_SIZE * pixel_size;
		}
	}