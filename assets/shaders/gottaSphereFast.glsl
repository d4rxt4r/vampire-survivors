---
name: gottaSphereFast
type: fragment
uniform.scrollX: { "type": "1f", "value": 0.0 }
uniform.scrollY: { "type": "1f", "value": 0.0 }
uniform.scrollSpeed: { "type": "1f", "value": 1.0 }
---

#define ZERO (min(iFrame,0))
#define PI 3.1415926535898
#define FAR 12.

#extension GL_OES_standard_derivatives : enable
precision mediump float;

uniform float time;
uniform float scrollX;
uniform float scrollY;
uniform float scrollSpeed;
uniform vec2 resolution;
varying vec2 fragCoord;

float camYaw;
vec3 camPos;

// https://iquilezles.org/articles/checkerfiltering
float checkersGradBox( in vec2 p )
{
    vec2 w = fwidth(p) + 0.001;	
    vec2 i = 2.0*(abs(fract((p-0.5*w)*0.5)-0.5)-abs(fract((p+0.5*w)*0.5)-0.5))/w;
    return 0.5 - 0.5*i.x*i.y;
}

vec3 distortPos(in vec3 pos)
{
    vec3 p = pos;
    float xx = (p - camPos).x;
    float zz = (p - camPos).z;
    float xxx = -(cos(camYaw)*zz-sin(camYaw)*xx);
    float zzz = -(cos(camYaw)*xx+sin(camYaw)*zz);
    float cx = cos(xxx * 0.3 ) * 1.1;
    if (cx < 0.0) cx *= 2.0;
    float cz = cos((zzz + 3.0)* 0.3 ) * 1.1;
    if (cz < 0.0) cz *= 1.5;
    p.y -= cx + cz;
    return p;
}

vec2 map(vec3 pos)
{
    vec3 p = distortPos(pos);
    vec2 res;

    res.x = FAR; // distance
    res.y = 0.0; // material id

    // floor plane
    if(p.y > 0.0) res = vec2(min(FAR, p.y), 1.);
    return res;
}

vec3 get_normal(vec3 p) {
    const vec2 e = vec2(0.0001, 0);
    return normalize(vec3(map(p + e.xyy).x - map(p - e.xyy).x,
                          map(p + e.yxy).x - map(p - e.yxy).x,
                          map(p + e.yyx).x - map(p - e.yyx).x));
}

vec2 intersect(vec3 ro, vec3 rd)
{
    float t = 0.0, dt;
    vec2 r;
    for (int i = 0; i < 128; i++){
        r = map(ro + rd * t);
        dt = r.x;
        if (dt < 0.002 || t > FAR) { break; }
        t += dt * 0.8;
    }
    return vec2(t, r.y);
}

vec4 lighting(vec3 rd, vec3 ro, vec3 pos, vec3 n, float matid)
{
    if (matid < 1.0){
        return vec4(0.0);
    }
    float z = length(pos - ro);
    vec3 matte = vec3(1.0, 0.5, 0.1) * (vec3(0.4) + vec3(checkersGradBox(vec2(pos.x, pos.z))));
    vec3 lp0 = camPos + vec3(0.0, 1.0, -2.0);
    vec3 ld0 = normalize(lp0 - pos);
    float dif = max(0.0, dot(n, ld0));
    vec3 lin = vec3(0.0);
    float spe = max(0.0, pow(clamp(dot(ld0, reflect(rd, n)), 0.0, 1.0), 20.0));
    lin += (1.0 + dif);
    lin = lin * 0.22 * matte;

    return vec4( lin.xyz, 1.0);
}

vec4 shade(vec3 ro, vec3 rd)
{
    vec4 col = vec4(0.0, 0.0, 0.0, 0.0);
    vec2 res = intersect(ro, rd);
    if(res.x < FAR)
    {
        vec3 pos = ro + rd * res.x;
        vec3 n = get_normal(pos);
        col = lighting(rd,ro, pos, n, res.y);
    }
    return col;
}

void updateCamera( in vec2 fragCoord, out vec3 rayOrigin, out vec3 rayDirection )
{
    vec2 uv = (fragCoord.xy - resolution.xy * 0.5)/ resolution.xy;
    uv.x *= resolution.x / resolution.y;
    float velocity = scrollSpeed * 0.0002;

    float xMove = -scrollX * velocity;
    float yMove = scrollY * velocity;

    vec3 ro = vec3(xMove, 4.5, yMove);
    vec3 ta = ro + vec3(0.0, 0.85, 1.0);

    float FOV = 1.0;
    vec3 fwd = normalize(ro - ta);
    vec3 rgt = normalize(vec3(fwd.z, 0., -fwd.x ));
    vec3 up = cross(fwd, rgt);
    vec3 rd = fwd + FOV*(uv.x*rgt + uv.y*up);
    camYaw = atan( fwd.z, fwd.x );
    rd = normalize(rd);

    rayOrigin = ro;
    rayDirection = normalize(rd);

    camPos = ro;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec3 ro, rd;
    updateCamera(fragCoord, ro, rd);
    vec4 col = shade(ro, rd);
    col.xyz = pow(clamp(col.xyz, 0.0, 1.0), vec3(0.45));
    col.xyz = mix(col.xyz, vec3(dot(col.xyz, vec3(0.33))), -0.5);
    fragColor = col;
}

void main(void)
{
    mainImage(gl_FragColor, fragCoord.xy);
}