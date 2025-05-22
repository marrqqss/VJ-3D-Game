shader_type sky;

uniform vec3 sky_color : source_color = vec3(0.03, 0.05, 0.11);

uniform vec3 star_color : source_color = vec3(0.8, 1.0, 0.3);
uniform float star_density : hint_range(0.0, 1.0) = 0.08;
uniform float star_size : hint_range(0.0, 0.1) = 0.02;

uniform bool enable_twinkle = true;
uniform float twinkle_speed : hint_range(0.0, 5.0) = 1.0;
uniform float twinkle_intensity : hint_range(0.0, 1.0) = 0.5;

vec3 hash3(vec3 p) {
    p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
             dot(p, vec3(269.5, 183.3, 246.1)),
             dot(p, vec3(113.5, 271.9, 124.6)));
    return fract(sin(p) * 43758.5453123);
}

float voronoi(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    float res = 1.0;
    for (int k = -1; k <= 1; ++k)
    for (int j = -1; j <= 1; ++j)
    for (int i = -1; i <= 1; ++i) {
        vec3 b = vec3(float(i), float(j), float(k));
        vec3 r = b - f + hash3(p + b);
        float d = dot(r, r);
        res = min(res, d);
    }
    return sqrt(res);
}

void sky() {
    vec3 dir = normalize(EYEDIR);
    float v = voronoi(dir * 100.0);
    float star = smoothstep(star_size, 0.0, v);

    if (enable_twinkle) {
        float twinkle = sin(TIME * twinkle_speed + v * 100.0) * 0.5 + 0.5;
        star *= mix(1.0 - twinkle_intensity, 1.0, twinkle);
    }

    COLOR = sky_color + star * star_color * star_density;
}
