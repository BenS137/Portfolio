shader_type canvas_item;

// Stomp-Cooldown Shader-Wert
// 0.0 = kein Stomp-Cooldown-Effekt
// 1.0 = voller Stomp-Cooldown-Effekt
uniform float cooldown_progress : hint_range(0.0, 1.0) = 0.0;

// Duck-Invincibility aktiv
// 0.0 = nicht invincible
// 1.0 = volle Invincibility-Farbe
uniform float duck_invincible_progress : hint_range(0.0, 1.0) = 0.0;

// Duck-Invincibility ist wieder verfügbar
// 0.0 = nicht ready
// 1.0 = ready Effekt sichtbar
uniform float duck_invincible_ready : hint_range(0.0, 1.0) = 0.0;

// Farbe für Stomp-Cooldown
// rot/orange = Fähigkeit gerade nicht verfügbar
uniform vec4 cooldown_color : source_color = vec4(1.0, 0.15, 0.0, 1.0);

// Farbe während Duck-Invincibility aktiv ist
// gold/gelb = geschützt
uniform vec4 duck_invincible_color : source_color = vec4(1.0, 0.9, 0.1, 1.0);

// Farbe, wenn Duck-Invincibility wieder ready ist
// grün = Fähigkeit verfügbar
uniform vec4 duck_ready_color : source_color = vec4(0.1, 0.85, 1.0, 1.0);


void fragment() {
	// Originalfarbe vom Sprite holen
	vec4 tex_color = texture(TEXTURE, UV);

	// Wir starten mit der normalen Sprite-Farbe
	vec3 final_color = tex_color.rgb;

	// Stomp-Cooldown Effekt:
	// Je höher cooldown_progress ist, desto stärker wird rot/orange reingemischt
	final_color = mix(final_color, cooldown_color.rgb, cooldown_progress * 0.75);

	// Duck-Invincibility aktiv:
	// Goldener pulsierender Effekt
	float invincible_pulse = sin(TIME * 16.0) * 0.5 + 0.5;
	vec3 invincible_color = duck_invincible_color.rgb + vec3(invincible_pulse * 0.25);

	// Gold wird nur sichtbar, wenn duck_invincible_progress > 0 ist
	final_color = mix(final_color, invincible_color, duck_invincible_progress);

	// Duck-Invincibility ready:
	// Grüner subtiler Pulse, wenn die Fähigkeit wieder verfügbar ist
	float ready_pulse = sin(TIME * 6.0) * 0.5 + 0.5;
	float ready_strength = duck_invincible_ready * (0.25 + ready_pulse * 0.25);

	final_color = mix(final_color, duck_ready_color.rgb, ready_strength);

	// Alpha bleibt original, damit transparente Pixel transparent bleiben
	COLOR = vec4(final_color, tex_color.a);
}