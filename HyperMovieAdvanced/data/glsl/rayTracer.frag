//grid code originally appears: https://github.com/diroru/domemod
#define PI 3.1415926535897932384626433832795

uniform sampler2D lookupTexBack;
uniform sampler2D lookupTexFront;
uniform sampler2D sliceTex;

uniform float sliceColCount;
//uniform float sliceRowCount;
uniform float sliceNormWidth;
uniform float sliceNormHeight;
uniform float sliceCount;
uniform float currentIndex;

varying vec2 vertTexCoord;

vec4 getColor(vec4 start, vec4 end, float f, float sliceCount) {
  if (start.a == 0.0 && end.a == 0.0) {
    return vec4(0.0);
  }
  vec3 v = mix(start.xyz, end.xyz, f);
  float sliceIndex = mod(round(v.z * (sliceCount-1.0)) + currentIndex, sliceCount);
  float s = (mod(sliceIndex, sliceColCount) + v.x) * sliceNormWidth;
  float t = (floor(sliceIndex / sliceColCount) + v.y) * sliceNormHeight;
  return texture(sliceTex, vec2(s,1.0-t));
  //return vec4(v, 0.1);
}

void main() {
  float steps = 100.0;
  vec2 st = vec2(vertTexCoord.x, 1.0 - vertTexCoord.y);
  vec4 rayStart = texture(lookupTexFront, st);
  vec4 rayEnd = texture(lookupTexBack, st);
  float alphaCumulative = 0.0;
  vec4 colourCumulative = vec4(0.0);
  for (float i = 0; i < steps; i += 1.0) {
    vec4 nextColor = getColor(rayStart, rayEnd, i / steps, sliceCount);
    colourCumulative += nextColor * nextColor.a; //kind of additive mix
    alphaCumulative += nextColor.a;
    if (alphaCumulative >= 1.0) {
      break;
    }
  }
  colourCumulative.a = 1.0;
  gl_FragColor = colourCumulative;
}
