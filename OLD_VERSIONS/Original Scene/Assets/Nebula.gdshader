shader_type spatial;
uniform sampler2D noise1;
uniform sampler2D noise2;
uniform sampler2D gradient;

uniform bool useMask;
uniform sampler2D mask;

uniform float starMin:hint_range(0.0,0.01) = 0.0051;
uniform float starMax: hint_range(0.0,0.1) = 0.0069;

float rng(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float fbm (float coords) {
	float value = 0.0;
	float scale = 0.5;
	
	for(int i = 0; i < 4; i++)
	{
		value += coords * scale;
		coords *= 2.0;
		scale *= 0.5;
	}
	return value;
	
}

void fragment() {
	vec2 uv = UV*0.5;
	
	vec2 distortion = SCREEN_UV;
	distortion.x += 5.0;
	
	vec4 tex = texture(noise1, uv + (vec2(sin(0.01*TIME), cos(0.01*TIME)))) / texture(noise2, cos(0.1*TIME)*uv+ (vec2(cos(0.01*TIME), sin(0.01*TIME))));
	
	tex.a = smoothstep(vec3(0.5), vec3(1.0), tex.rgb).b;
	
	if(tex.a > 0.95) {
		// Initiate stars.exe
		float weight = rng(0.5*UV * sin(SCREEN_UV));
		
		//weight = step(starAmount, weight);
		if(weight < starMax && weight > starMin)
			tex.rgb += 2.0 * (max(sin(pow(weight, 2.0)* 520.0 * TIME), 0.0) ) * tex.a * 8050.0 * weight;
	}
	
	
	tex *= texture(gradient, ((smoothstep(0.0, 0.9,floor(tan(TIME*20.0)))) - sin(UV * vec2(cos(TIME)/2.0 + 0.5, 0.5))));
	//tex.rgb *= vec3(0.7);
	//tex.a = fbm((tex.r + tex.b + tex.g) / 3.0);
	
	//tex = smoothstep(vec4(0.1,0.1,0.1,0.2), vec4(0.7,0.7,0.7,1.0), tex);
	ALBEDO = tex.rgb;
	
	if(useMask)
	{
		ALPHA *= texture(mask, UV ).r;
		ALPHA = smoothstep(0.1, 1.0, ALPHA);
	}

}