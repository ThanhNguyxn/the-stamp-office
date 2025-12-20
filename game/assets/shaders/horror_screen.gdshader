shader_type canvas_item;

// Horror screen effects - glitch, static, distortion
// Toggle different effects via uniforms

uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float static_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float chromatic_aberration : hint_range(0.0, 0.1) = 0.0;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float scan_line_intensity : hint_range(0.0, 1.0) = 0.1;
uniform float time_scale : hint_range(0.0, 10.0) = 1.0;

uniform sampler2D screen_texture : hint_screen_texture;

float random(vec2 uv) {
	return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 uv) {
	vec2 i = floor(uv);
	vec2 f = fract(uv);
	float a = random(i);
	float b = random(i + vec2(1.0, 0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float time = TIME * time_scale;
	
	// Glitch effect - horizontal displacement
	if (glitch_intensity > 0.0) {
		float glitch = step(0.99 - glitch_intensity * 0.1, random(vec2(floor(time * 20.0), floor(uv.y * 50.0))));
		float offset = (random(vec2(time, floor(uv.y * 30.0))) - 0.5) * glitch_intensity * 0.2 * glitch;
		uv.x += offset;
	}
	
	// Chromatic aberration
	vec4 color;
	if (chromatic_aberration > 0.0) {
		float r = texture(screen_texture, uv + vec2(chromatic_aberration, 0.0)).r;
		float g = texture(screen_texture, uv).g;
		float b = texture(screen_texture, uv - vec2(chromatic_aberration, 0.0)).b;
		color = vec4(r, g, b, 1.0);
	} else {
		color = texture(screen_texture, uv);
	}
	
	// Static noise overlay
	if (static_intensity > 0.0) {
		float static_noise = random(uv + vec2(time * 100.0, 0.0));
		color.rgb = mix(color.rgb, vec3(static_noise), static_intensity * 0.3);
	}
	
	// Scan lines
	if (scan_line_intensity > 0.0) {
		float scan = sin(SCREEN_UV.y * 800.0) * 0.5 + 0.5;
		color.rgb *= 1.0 - (scan * scan_line_intensity * 0.2);
	}
	
	// Vignette
	if (vignette_intensity > 0.0) {
		vec2 vignette_uv = SCREEN_UV * (1.0 - SCREEN_UV.yx);
		float vignette = vignette_uv.x * vignette_uv.y * 15.0;
		vignette = pow(vignette, vignette_intensity);
		color.rgb *= vignette;
	}
	
	COLOR = color;
}
