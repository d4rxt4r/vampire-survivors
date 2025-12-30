---
name: rainbowCheckerboard
type: fragment
---

precision mediump float;

uniform float time;
uniform vec2 resolution;
varying vec2 fragCoord;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	// Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/resolution.xy;

    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(time+uv.xyx+vec3(0,2,4));

    // Output to screen
    fragColor = vec4(col,1.0);
    
    // CHECKERBOARD LOGIC:
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv2 = uv * vec2(-1, 1) + vec2(cos(time * 0.3) + time * 0.4, time * 0.4) * vec2(0.2, 0.3);
    // Time varying pixel color
    vec4 tmpColor = vec4(1.0, 1.0, 1.0, 0.0);
    if (sin(uv2.x * 17.0 * 3.1415) > .0) tmpColor = vec4(0.0, 0.0, 0.0, 1.0);    
    if (sin(uv2.y * 10.0 * 3.1415) > 0.0) tmpColor = 1.0 - tmpColor;   
    // END CHECKERBOARD

    if (tmpColor.a > 0.0) fragColor = mix(fragColor, tmpColor, abs(sin(time * 0.5)) + 0.2 + uv.x / 10.0);
}

void main(void)
{
    mainImage(gl_FragColor, fragCoord.xy);
}