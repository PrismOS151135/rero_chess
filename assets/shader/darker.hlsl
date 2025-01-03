#pragma language glsl3

uniform float k;

vec4 effect(vec4 color, sampler2D tex, vec2 texCoord, vec2 scrCoord) {
    return vec4(
        vec3(color) * k,
        texture2D(tex, texCoord).a * color.a
    );
}
