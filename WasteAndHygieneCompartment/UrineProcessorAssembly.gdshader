shader_type canvas_item;

void fragment() {
    float y = UV.y;

    vec3 red = vec3(1.0, 0.0, 0.0);
    vec3 yellow = vec3(1.0, 1.0, 0.0);
    vec3 green = vec3(0.0, 1.0, 0.0);
    vec3 color;

    // Define green region bounds
    float fade_half = 0.025;       // 2.5% for each gradient
    float green_half = 0.025;      // 5% / 2 = 2.5% for solid green
    float center = 0.5;

    float fade_start = center - fade_half - green_half;   // 0.475
    float green_start = center - green_half;              // 0.4875
    float green_end = center + green_half;                // 0.5125
    float fade_end = center + fade_half + green_half;     // 0.525

    if (y < fade_start) {
        // Red → Yellow
        float t = y / fade_start;
        color = mix(red, yellow, t);
    } else if (y < green_start) {
        // Yellow → Green fade
        float t = (y - fade_start) / (green_start - fade_start);
        color = mix(yellow, green, t);
    } else if (y <= green_end) {
        // Solid green band
        color = green;
    } else if (y < fade_end) {
        // Green → Yellow fade
        float t = (y - green_end) / (fade_end - green_end);
        color = mix(green, yellow, t);
    } else {
        // Yellow → Red
        float t = (y - fade_end) / (1.0 - fade_end);
        color = mix(yellow, red, t);
    }

    COLOR = vec4(color, 1.0);
}
