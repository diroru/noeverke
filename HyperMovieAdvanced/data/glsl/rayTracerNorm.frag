//grid code originally appears: https://github.com/diroru/domemod
#define PI 3.1415926535897932384626433832795

uniform sampler2D lookupTexBack;
uniform sampler2D lookupTexFront;
uniform sampler2D sliceTex;

uniform vec2 canvasSize;

uniform float sliceColCount;
//uniform float sliceRowCount;
uniform float sliceNormWidth;
uniform float sliceNormHeight;
uniform float sliceCount;
uniform float currentIndex;
uniform float steps;
uniform float pixelFactor;

varying vec2 vertTexCoord;

vec4 getPos(vec4 start, vec4 end, float f, float sliceCount) {
  if (start.a == 0.0 && end.a == 0.0) {
    return vec4(0.0);
  }
  vec3 v = mix(start.xyz, end.xyz, f);
  float sliceIndex = mod(round(v.z * (sliceCount-1.0)) + currentIndex, sliceCount);
  float s = (mod(sliceIndex, sliceColCount) + v.x) * sliceNormWidth;
  float t = (floor(sliceIndex / sliceColCount) + v.y) * sliceNormHeight;
  vec4 color = texture(sliceTex, vec2(s,1.0-t));
  return vec4(v, color.a);
  //return vec4(v, 0.1);
}

vec4 getPosInSpace(vec2 theVertexCoord) {
  vec2 st = vec2(theVertexCoord.x, 1.0 - theVertexCoord.y);
  vec4 rayStart = texture(lookupTexFront, st);
  vec4 rayEnd = texture(lookupTexBack, st);
  float alphaCumulative = 0.0;
  vec4 pos = vec4(0.0);
  for (float i = 0; i < steps; i += 1.0) {
    vec4 nextPos = getPos(rayStart, rayEnd, i / steps, sliceCount);
    alphaCumulative += nextPos.a;
    if (alphaCumulative >= 1.0) {
      pos = nextPos;
      break;
    }
  }
  return pos;
}

void main() {
  vec2 pixelSize = vec2(pixelFactor) / canvasSize;
  vec4 p0 = getPosInSpace(vertTexCoord);
  vec4 p1 = getPosInSpace(vec2(vertTexCoord.s - pixelSize.s, vertTexCoord.t));
  vec4 p2 = getPosInSpace(vec2(vertTexCoord.s, vertTexCoord.t - pixelSize.t));

  vec3 v0 = p2.xyz - p0.xyz;
  vec3 v1 = p1.xyz - p0.xyz;
  vec3 w = normalize(cross(v0, v1)) * 0.5 + vec3(0.5);

  gl_FragColor = vec4(w, 1.0);
  //gl_FragColor = vec4(p0.z, p0.z, p0.z, 1.0);
}
