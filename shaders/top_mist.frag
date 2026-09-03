#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uStrength;
uniform float uDpr;

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

  // Linear top-down wash — resolution-independent fade.
  float fade = exp(-3.2 * y);
  float alpha = uStrength * fade;

  // Pixel-stable dither (scales with DPR) to hide 8-bit banding without blur.
  if (fade > 0.04 && fade < 0.92) {
    vec2 cell = floor(coord * max(uDpr, 1.0));
    float dither = (hash21(cell) - 0.5) * (1.0 / 255.0);
    alpha = clamp(alpha + dither * fade, 0.0, 1.0);
  }

  vec3 mint = vec3(0.0, 0.901960784, 0.650980392);
  fragColor = vec4(mint * alpha, alpha);
}
