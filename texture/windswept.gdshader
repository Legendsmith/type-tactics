shader_type canvas_item;

uniform float wind_dir_angle = 0.0;       // wind direction in degrees clockwise from +x
uniform float wind_speed = 100.0;         // speed of patch movement in pixels per second
uniform bool  use_wind_gusts = false;      // toggle smooth speed variation
uniform float patch_width_px = 300.0;     // horizontal size of noise patches
uniform float patch_height_px = 10.0;     // vertical thickness of each band
uniform float pixel_size_px : hint_range(1.0, 64.0, 1.0) = 1.0; // pixel snap size
uniform float rotation_degrees = -15.0;   // rotation of patch bands
uniform float threshold = 0.6;            // noise cutoff controlling patch density
uniform float opacity = 0.1;              // alpha strength of visible patches

float hash(vec2 p) {
    // fast deterministic pseudo random per grid cell
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    // smooth value noise built from hashed grid corners
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x)
         + (c - a) * u.y * (1.0 - u.x)
         + (d - b) * u.x * u.y;
}

vec2 rotate(vec2 p, float angle_rad) {
    // rotates coordinates around origin
    float c = cos(angle_rad);
    float s = sin(angle_rad);
    return vec2(
        p.x * c - p.y * s,
        p.x * s + p.y * c
    );
}

void fragment() {
    // screen uv converted into pixel space
    vec2 p = SCREEN_UV / SCREEN_PIXEL_SIZE;

    // convert angle to direction vector in y-down space
    float wind_rad = radians(wind_dir_angle);
    vec2 wind_dir = -vec2(cos(wind_rad), sin(wind_rad));

    // animate noise sampling position
	float wind_gust_speed = 1.0; // max extra speed fraction
	float wind_gust_rate = 0.5;  // gust angular frequency
	
	if (use_wind_gusts) {
	    float phase = wind_gust_rate * TIME;

	    float dist = wind_speed * TIME * (1.0 + 0.5 * wind_gust_speed)
	               - wind_speed * (0.5 * wind_gust_speed / wind_gust_rate)
	                 * cos(phase);

	    p += wind_dir * dist;
	} else {
	    p += wind_dir * TIME * wind_speed;
	}

    // rotate noise space to tilt patches
    float angle = radians(rotation_degrees);
    p = rotate(p, angle);

    // enforce hard pixel snapping
    p = floor(p / pixel_size_px) * pixel_size_px;

    // split space into horizontal bands
    float band = floor(p.y / patch_height_px);

    // noise stretched along x to form elongated patches
    float x_noise = noise(vec2(p.x / patch_width_px, band * 0.25));
    float band_noise = hash(vec2(band, 19.0));
    float n = x_noise * 0.8 + band_noise * 0.2;

    // binary mask deciding where patches appear
    float mask = step(threshold, n);

    // sample base color including texture and tint
    vec4 base = texture(TEXTURE, UV) * COLOR;

    // reveal base color only inside patch mask
    base.a *= mask * opacity;
    COLOR = base;
}
