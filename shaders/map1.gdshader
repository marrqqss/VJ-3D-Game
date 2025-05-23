shader_type sky;

uniform float time_speed = 0.5;

void sky() {
    float t = TIME * time_speed;
    float gradient = clamp(EYEDIR.y * 0.5 + 0.5, 0.0, 1.0);
    float r = sin(t + gradient * 3.1415) * 0.1 + 0.5;
    float g = sin(t + gradient * 3.1415 + 2.0) * 0.1 + 0.5;
    float b = sin(t + gradient * 3.1415 + 4.0) * 0.1 + 0.5;
    COLOR = vec3(r, g, b);
}
