#include <flutter/runtime_effect.glsl>

uniform float uTime;
uniform vec2 uResolution;

out vec4 fragColor;

void main() {
    vec2 st = FlutterFragCoord().xy / uResolution.xy;
    vec3 color = vec3(0.0);

    // Create a plasma effect
    float t = uTime * 0.5;
    
    // Pattern 1: Moving circles
    float val = sin(st.x * 10.0 + t) + cos(st.y * 10.0 + t);
    
    // Pattern 2: Diagonal waves
    val += sin((st.x + st.y) * 10.0 - t);
    
    // Pattern 3: Circular waves from center
    vec2 center = vec2(0.5);
    float dist = distance(st, center);
    val += sin(dist * 20.0 - t * 2.0);

    // Map value to colors
    // Normalize val which can range roughly from -3 to 3
    val = val / 3.0; 

    // Colorful mix
    color.r = 0.5 + 0.5 * sin(val * 3.14 + t);
    color.g = 0.5 + 0.5 * sin(val * 3.14 + t + 2.0);
    color.b = 0.5 + 0.5 * sin(val * 3.14 + t + 4.0);

    fragColor = vec4(color, 1.0);
}
