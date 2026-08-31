#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uStrength;

out vec4 fragColor;

float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

void main() {
  vec2 coord = FlutterFragCoord().xy;
  vec2 uv = coord / uSize;
  float y = uv.y;

  // Linear top-down wash — turquoise at top, fades to black.
  float fade = exp(-3.2 * y);
  float alpha = uStrength * fade;

  // Subtle grain masks 8-bit banding and reads as soft mist/dust.
  float grain = (hash21(coord * 0.35) - 0.5) * 0.04;
  alpha = clamp(alpha + grain * fade, 0.0, 1.0);

  vec3 mint = vec3(0.0, 0.901960784, 0.650980392);
  fragColor = vec4(mint * alpha, alpha);
}
