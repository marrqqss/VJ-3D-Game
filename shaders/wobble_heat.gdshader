shader_type spatial;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float time_speed : hint_range(0.01, 0.1) = 0.05;
uniform float max_shift : hint_range(0.0, 10.0) = 2.5;
uniform sampler2D noise_texture;

void fragment() {
    vec2 uv = SCREEN_UV;
    float noise = texture(noise_texture, uv * 5.0 + TIME * time_speed).r;
    vec2 distortion = vec2(sin(noise * 10.0), cos(noise * 10.0)) * max_shift * noise;
    vec4 screen_color = texture(screen_texture, uv + distortion);
    ALBEDO = screen_color.rgb;
    ALPHA = screen_color.a * 0.2;
}

