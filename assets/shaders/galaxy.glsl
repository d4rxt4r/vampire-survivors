---
name: galaxyShader
type: fragment
author: rifke
uniform.size: { "type": "1f", "value": 16.0 }
uniform.force: { "type": "1f", "value": 1.0 }
uniform.speed: { "type": "1f", "value": 1.0 }
---

precision mediump float;

uniform float size;
uniform float time;
uniform float force;
uniform float speed;
uniform vec2 resolution;
varying vec2 fragCoord;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy/resolution.xy)-.5;
	float len = length(uv.xy);
	
    float t = speed*time;
	float myTime = t  +  (5.+sin(t))*(force*.11) / (len+.07);
	float si = sin(myTime), co = cos(myTime);
	uv *= mat2(co, si, -si, co);

	float c=0., v1=0., v2=0., v3;  vec3 p;
	
	for (int i = 0; i < 100; i++) {
		p = .035*float(i) *  vec3(uv, 1.);
		p += vec3(.22,  .3,  -1.5 -sin(t*1.3)*.1);
		
		for (int i = 0; i < 8; i++)
			p = abs(p) / dot(p,p) - 0.659;

		float p2 = dot(p,p)*.0015;
		v1 += p2 * ( 1.8 + sin(len*13.0  +.5 -t*2.) );
		v2 += p2 * ( 1.5 + sin(len*13.5 +2.2 -t*3.) );
	}
	
	c = length(p.xy) * .175;
	v1 *= smoothstep(.7 , .0, len);
	v2 *= smoothstep(.6 , .0, len);
	v3  = smoothstep(.15, .0, len);

	vec3 col = vec3(c,  (v1+c)*.25,  v2);
	col = col  +  v3*.9;
	fragColor=vec4(col, 1.);
}

void main(void)
{
    mainImage(gl_FragColor, fragCoord.xy);
    gl_FragColor.a = 1.0;
}