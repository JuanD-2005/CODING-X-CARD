shader_type canvas_item;

const float time = float(0.0);
uniform float speed : hint_range(0.0, 5.0);
const vec4 target_color = vec4(0.0,0.0,0.0,0.1);
const float tolerance = float(1.0);


uniform float NoiseResolution :hint_range(0.0, 4.0)  ;
uniform float Lacunarity :hint_range(0.0, 5.0) ;
uniform float Gain :hint_range(0.0, 1.6) ;
uniform float Ball_rad : hint_range(0.0, 0.45);
uniform float Ball_roll_spd :hint_range(0.0, 1.5);
uniform float Dark_lava_spd :hint_range(0.0, 1.05);
uniform float Dark_island_spd :hint_range(0.0, 1.5);


vec2 random2D(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

float random1D(vec2 p) {
    return fract(sin(dot(p.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise2D(vec2 _pos) {
    vec2 i = floor(_pos);
    vec2 f = fract(_pos);
    float a = random1D(i);
    float b = random1D(i + vec2(1.0, 0.0));
    float c = random1D(i + vec2(0.0, 1.0));
    float d = random1D(i + vec2(1.0, 1.0));
    vec2 u = smoothstep(0.0, 1.0, f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 _pos) {
	float _time = TIME * speed;
    _pos.y += _time * Ball_roll_spd ;
    _pos.x += sin(_time * Ball_roll_spd );
    float ts = _time * Dark_lava_spd ;
    float val = 0.0;
    float amp = 0.4;
    for (int i = 0; i < 4; ++i) {
        val += amp * noise2D(_pos + ts);
        _pos *= Lacunarity;
        amp *= Gain;
    }
    return val;
}

float voronoiIQ(vec2 _pos) {
	float _time = TIME * speed;
    _pos.y += _time * Ball_roll_spd;
    _pos.x += sin(_time * Ball_roll_spd);
    vec2 p = floor(_pos);
    vec2 f = fract(_pos);
    float res = 0.0;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 b = vec2(float(i), float(j));
            vec2 pnt = random2D(p + b);
            pnt = 0.5 + 0.5 * sin((_time * Dark_island_spd) + 6.2831 * pnt);
            vec2 r = vec2(b) - f + pnt;
            float d = dot(r, r);
            res += exp(-32.0 * d);
        }
    }
    return -(1.0 / 32.0) * log(res);
}

void fragment() {
    vec2 uv = UV;
    uv.x += 0.33;
    vec2 pos1 = uv - vec2(0.825, 0.5);
    vec3 pos = vec3(pos1, sqrt(Ball_rad * Ball_rad - pos1.x * pos1.x - pos1.y * pos1.y) / NoiseResolution);

    float dist = distance(pos.xy, vec2(0.0, 0.0));
    pos /= vec3(1.0 * pos.z, 1.0 * pos.z, 0.0);

    vec4 color = vec4(0.0, 0.0, 0.0,0.0);

    if (dist > (Ball_rad - Ball_rad * 0.125)) {
        color = vec4(0.0,0.0, 0.0, 0.1);
        color.r += 1.0 - smoothstep(Ball_rad - Ball_rad * 0.35, Ball_rad + 0.125, dist);
    } else {
        color.rg = vec2(voronoiIQ(pos.xy));
        color.r += 0.25 + fbm(pos.xy);
    }


    float color_distance = distance(color, target_color);
    if (color_distance < tolerance) {
        COLOR = vec4(color.xyz, 0.0);
    } else {
        COLOR = vec4(color.xyz, 1.0);
    }
}


