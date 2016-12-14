const number radius = 0.009;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
  vec4 c = vec4( Texel(texture, texture_coords) );
  float u = texture_coords[0];
  float v = texture_coords[1];

  // Simple blurring effect, otherwise it looks gross.
  c += vec4( Texel(texture, vec2(u,v-radius)) );
  c += vec4( Texel(texture, vec2(u,v+radius)) );
  c += vec4( Texel(texture, vec2(u-radius,v)) );
  c += vec4( Texel(texture, vec2(u+radius,v)) );
  c += vec4( Texel(texture, vec2(u-radius,v-radius)) );
  c += vec4( Texel(texture, vec2(u+radius,v-radius)) );
  c += vec4( Texel(texture, vec2(u+radius,v+radius)) );
  c += vec4( Texel(texture, vec2(u-radius,v+radius)) );
  c /= 9;
  return c;
}
