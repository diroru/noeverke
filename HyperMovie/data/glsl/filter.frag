//grid code originally appears: https://github.com/diroru/domemod
#define PI 3.1415926535897932384626433832795

uniform sampler2D srcTex;

uniform float redMin;
uniform float redMax;
uniform float blueMin; //z coordinate
uniform float blueMax; //along the z axis
uniform float greenMin;
uniform float greenMax;

varying vec2 vertTexCoord;

void main() {
  vec2 st = vec2(vertTexCoord.x, 1.0 - vertTexCoord.y);
  vec4 srcColor = texture(srcTex, vertTexCoord);
  if (srcColor.r < redMin || srcColor.r > redMax || srcColor.b < blueMin || srcColor.b > blueMax || srcColor.g < greenMin || srcColor.g > greenMax) {
    discard;
  } else {
    gl_FragColor = srcColor;
  }
}
