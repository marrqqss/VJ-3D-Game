shader_type sky;

uniform float time_speed = 0.05; 

const vec3 color1 = vec3(1.0, 0.8, 0.6);   // Soft orange (morning)
const vec3 color2 = vec3(0.9, 0.7, 0.5);   // Warm beige (midday)
const vec3 color3 = vec3(0.8, 0.6, 0.4);   // Deep amber (afternoon)
const vec3 color4 = vec3(0.7, 0.5, 0.3);   // Dusk brown
const vec3 color5 = vec3(0.8, 0.3, 0.1);   // Night brown
const vec3 color6 = vec3(0.6, 0.1, 0.6);   // Midnight black

void sky() {
    float t = mod(TIME * time_speed, 1.0); // Loop over time

    // Calculate weights using sine functions for smooth transitions
    float w1 = sin(2.0 * PI * t) * 0.5 + 0.5;
    float w2 = sin(2.0 * PI * t + PI / 3.0) * 0.5 + 0.5;
    float w3 = sin(2.0 * PI * t + 2.0 * PI / 3.0) * 0.5 + 0.5;
    float w4 = sin(2.0 * PI * t + PI) * 0.5 + 0.5;
    float w5 = sin(2.0 * PI * t + 4.0 * PI / 3.0) * 0.5 + 0.5;
    float w6 = sin(2.0 * PI * t + 5.0 * PI / 3.0) * 0.5 + 0.5;

    // Normalize weights
    float sum = w1 + w2 + w3 + w4 + w5 + w6;
    w1 /= sum;
    w2 /= sum;
    w3 /= sum;
    w4 /= sum;
    w5 /= sum;
    w6 /= sum;

    // Interpolate between colors
    vec3 top_color = color1 * w1 + color2 * w2 + color3 * w3 + color4 * w4 + color5 * w5 + color6 * w6;
    vec3 bottom_color = color6 * w1 + color5 * w2 + color4 * w3 + color3 * w4 + color2 * w5 + color1 * w6;

    float gradient = clamp(EYEDIR.y * 0.5 + 0.5, 0.0, 1.0);
    COLOR = mix(bottom_color, top_color, pow(gradient, 1.5));
}
