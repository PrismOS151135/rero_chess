extern float k;

vec4 effect(vec4 color, sampler2D tex, vec2 texCoord, vec2 scrCoord) {
    return vec4(
        mix(vec3(color), vec3(1.0), k),
        texture2D(tex, texCoord).a*color.a
    );
}
