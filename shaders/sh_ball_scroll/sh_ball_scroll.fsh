precision highp float;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_scroll;
uniform vec4 u_uv_bounds;

void main() {
    vec2 uv_size = u_uv_bounds.zw - u_uv_bounds.xy;
    vec2 local_uv = (v_vTexcoord - u_uv_bounds.xy) / uv_size;
    vec2 moving_local = fract(local_uv + u_scroll);
    vec2 moving_uv = u_uv_bounds.xy + moving_local * uv_size;

    vec4 original = texture2D(gm_BaseTexture, v_vTexcoord);
    vec4 moving = texture2D(gm_BaseTexture, moving_uv);
    vec3 base_colour = texture2D(gm_BaseTexture,
        u_uv_bounds.xy + vec2(0.75, 0.5) * uv_size).rgb;
    float source_radius = length((moving_local - 0.5) * 2.0);
    float target_radius = length((local_uv - 0.5) * 2.0);
    float interior = (1.0 - smoothstep(0.78, 0.84, source_radius)) * moving.a;
    vec3 rolling_colour = mix(base_colour, moving.rgb, interior);
    float fixed_edge = smoothstep(0.78, 0.90, target_radius);
    vec3 colour = mix(rolling_colour, original.rgb, fixed_edge);
    gl_FragColor = v_vColour * vec4(colour, original.a);
}
