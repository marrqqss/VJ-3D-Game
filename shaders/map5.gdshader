shader_type sky;

uniform vec3 base_color : source_color = vec3(0.05, 0.05, 0.1);

uniform float cloud_speed = 0.1;
uniform float cloud_scale = 1.5;
uniform float cloud_contrast = 2.0;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    for (int i = 0; i < 5; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void sky() {
    vec2 uv = vec2(EYEDIR.xz) * cloud_scale;
    uv += vec2(TIME * cloud_speed, TIME * cloud_speed);
    float cloud = fbm(uv);
    cloud = pow(cloud, cloud_contrast);

    vec3 color = base_color + cloud * 0.2;

    COLOR = color;
}
