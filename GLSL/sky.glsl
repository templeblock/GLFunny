uniform float     time;
uniform vec2      viewport;
uniform vec3      cameraPos;
uniform vec4      worldLight;
uniform mat4      projectionInv;
uniform mat4      cameraViewInv;

vec3 yztozy(vec3 p){
    return vec3(p.x,p.z,p.y);
}

vec2 coordToUV(vec2 coord){
    return 2.0*coord/viewport-1.0;
}

vec3 uvToWorldDir(vec2 uv){
     vec4 camdir = projectionInv*vec4(uv,1,1);
     camdir = camdir/camdir.w;
     vec4 dirp = cameraViewInv*camdir;
     return normalize(dirp.xyz-cameraPos);
}



const float coeiff = 0.25;
const vec3 totalSkyLight = vec3(0.3, 0.5, 1.0);

vec3 mie(float dist, vec3 sunL){
    return max(exp(-pow(dist, 0.25)) * sunL - 0.4, 0.0);
}

vec3 getSky(vec3 dir, vec3 sunPos){
	
	float sunDistance = distance(dir , clamp(sunPos, -1.0, 1.0));
	
	float scatterMult = clamp(sunDistance, 0.0, 1.0);
	float sun = clamp(1.0 - smoothstep(0.01, 0.011, scatterMult), 0.0, 1.0);
	
	float dist = dir.z;
	dist = (coeiff * mix(scatterMult, 1.0, dist)) / dist;
    
    vec3 mieScatter = mie(sunDistance, vec3(1.0));
	
	vec3 color = dist * totalSkyLight;
    
    color = max(color, 0.0);
    
	color = max(mix(pow(color, 1.0 - color),
	color / (2.0 * color + 0.5 - color),
	clamp(sunPos.z * 2.0, 0.0, 1.0)),0.0)
	+ sun + mieScatter;
	
	color *=  (pow(1.0 - scatterMult, 10.0) * 10.0) + 1.0;
	
	float underscatter = distance(sunPos.z * 0.5 + 0.5, 1.0);
	
	color = mix(color, vec3(0.0), clamp(underscatter, 0.0, 1.0));
	
	return color;	
}

void main(){
    
    vec2 uv = coordToUV(gl_FragCoord.xy);
    vec3 dir = uvToWorldDir(uv);
    vec3 sunPos = normalize(worldLight.xyz);
	vec3 color = getSky(dir,sunPos);
	color = color / (2.0 * color + 0.5 - color);
	gl_FragColor = vec4(color, 1.0);
}