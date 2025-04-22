shader_type canvas_item;

uniform float time : hint_range(0.0,10.0) = 0.0;
uniform float freq : hint_range(0.5,5.0) = 1.0;
uniform float speed : hint_range(0.0,1.0) = 0.1;      // overall scroll speed
uniform float waves : hint_range(1.0,20.0) = 10.0;    // how many peaks across the panel
uniform float thickness : hint_range(0.005,0.05) = 0.02;  // line “thickness”

void fragment() {
    // 1) Always draw a solid dark background
    vec4 bg = vec4(0.0, 0.0, 0.0, 1.0);

    // 2) Compute a smooth wave that scrolls slowly
    //    UV.x * waves     → number of cycles across X
    //    (time * speed)   → scrolling offset
    float phase = (UV.x * waves - time * speed) * freq;
    float wave = sin(phase);

    // 3) Convert that into a soft line: 
    //    distance from mid‑line, with a smooth edge
    //    abs(wave) near 0 = on the line
    float dist = abs(wave);
    // smoothstep(edge1, edge2, x) fades from 1→0 as x goes  edge1→edge2
    float alpha = smoothstep(thickness, 0.0, dist - 0.5);

    // 4) Build the wave color (green) with that alpha
    vec4 wave_col = vec4(0.0, 1.0, 0.0, alpha);

    // 5) Composite over the background
    COLOR = mix(bg, wave_col, wave_col.a);
}
