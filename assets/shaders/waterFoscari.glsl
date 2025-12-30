---
name: waterFoscari
type: fragment
---

precision mediump float;

uniform float time;
uniform vec2 resolution;
varying vec2 fragCoord;

#define TAU 6.28318530718

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	float varTime = time * .5+23.0;
    // uv should be the 0-1 uv of texture...
	vec2 uv = fragCoord.xy / resolution.xy;
    
    vec2 p = mod(uv*6.28318530718, 6.28318530718)-250.0;

	vec2 i = vec2(p);
	float c = 1.0;
	float inten = .005;

	for (int n = 0; n < 5; n++) 
	{
		float t = varTime * (1.0 - (3.5 / float(n+1)));
		i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
		c += 1.0/length(vec2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
	}
	c /= float(5);
	c = 1.17-pow(c, 1.4);
	vec3 colour = vec3(pow(abs(c), 8.0));
    colour = clamp(colour + vec3(0.0, 0.35, 0.5), 0.0, 1.0);
	fragColor = vec4(colour, 1.0);
}

void main(void)
{
    mainImage(gl_FragColor, fragCoord.xy);
}