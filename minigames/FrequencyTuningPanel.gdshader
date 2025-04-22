shader_type canvas_item;

uniform float time = 0.0;
uniform float freq = 1.0;

void fragment() {
    vec4 background = vec4(0.0, 0.0, 0.0, 1.0);
    float wave = sin(UV.x * freq * 40.0 + time * freq * 5.0);
    float line = step(0.48, wave) - step(0.52, wave);
    vec4 wave_color = vec4(0.0, 1.0, 0.0, 1.0);
    COLOR = mix(background, wave_color, line);
}
