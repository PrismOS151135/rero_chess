vec4 effect(vec4 color, sampler2D tex, vec2 texCoord, vec2 scrCoord) {
    return vec4(1.0-(1.0-vec3(color))*0.626, texture2D(tex, texCoord).a);
}
