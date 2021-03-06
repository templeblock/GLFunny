#version 130
uniform vec2      viewport;//窗口分辨率

//坐标归一到[-1,1]
vec2 coord2uv(vec2 coord){
    return 2.0*coord/viewport.xy-1.0;
}

//通过uv计算本地坐标系下的射线方向
vec3 uv2ray(vec2 uv){
     vec4 camdir = gl_ProjectionMatrixInverse*vec4(uv,1,1);
     camdir = camdir/camdir.w;//W归一后 得出相机坐标体系下的点
     vec3 dir = mat3(gl_ModelViewMatrixInverse)*vec3(camdir);
     return normalize(dir);
}

//本地坐标系下的视点坐标
vec3 cameraPos(){
    return vec3(gl_ModelViewMatrixInverse*vec4(0,0,0,1));
}

//计算本地坐标系下的灯光方向（平行光）
vec3 lightPos(){
	return normalize(mat3(gl_ModelViewMatrixInverse)*gl_LightSource[0].position.xyz);
}

//本地坐标系下点光源坐标
vec3 spotLightPos(){    
    return vec3(gl_ModelViewMatrixInverse*gl_LightSource[0].position);
}


float sdsphere(vec3 pos,float r){
    return length(pos)-r;
}

float sdBox(vec3 p, vec3 radius)
{
  vec3 dist = abs(p) - radius;
  return min(max(dist.x, max(dist.y, dist.z)), 0.0) + length(max(dist, 0.0));
}

float cylCap(vec3 p, float r, float lenRad)
{
    float a = length(p.xy) - r;
    a = max(a, abs(p.z) - lenRad);
    return a;
}

// k should be negative. -4.0 works nicely.
// smooth blending function
float smin(float a, float b, float k)
{
	return log2(exp2(k*a)+exp2(k*b))/k;
}

float Repeat(float a, float len)
{
    return mod(a, len) - 0.5 * len;
}

vec2 matmin(vec2 v1,vec2 v2){
	return v1.x>v2.x?v2:v1;
}

vec2 Car(vec3 baseCenter)
{
    // bottom box
    float car = sdBox(baseCenter + vec3(0.0,0.01,-0.08), vec3(0.1,0.275,0.0225));
    // top box smooth blended
    car = smin(car, sdBox(baseCenter + vec3(0.0, 0.08,-0.16), vec3(0.05, 0.1, 0.005)), -16.0);
    // mirror the z axis to duplicate the cylinders for wheels
    vec3 wMirror = baseCenter + vec3(0.0, 0.0,-0.05);
    wMirror.y = abs(wMirror.y)-0.2;
    float wheels = cylCap((wMirror).yzx, 0.04, 0.135);
    // Set materials
    vec2 distAndMat = vec2(wheels, 0.1);	// car wheels
    // Car material is some big number that's unique to each car
    // so I can have each car be a different color
    distAndMat = matmin(distAndMat, vec2(car,0.5));	// car
    return distAndMat;
}


vec2 map(vec3 pos){
    return vec2(sdsphere(pos,1),0.5);/*Car(pos);*/
}

#define MAXSTEP 50 //最大逼近步数
#define TOLERANCE 0.001 // 距离需要减小到该值以下 
#define NORMALESP 0.01 //计算Normal需要的差值

//输入:视点坐标，射线方向;
//输出:最近点和对应材质系数。
bool marching(vec3 pos,vec3 ray,out vec3 closeing,out float material){
    int step =0;
	float mindist = 1;
    vec2 res;
    do{
        res = map(pos);
        if(res.x<mindist){
            mindist = res.x;
            material = res.y;
            closeing = pos;
        }
        
        pos+= ray*res.x;       
        step++;
    }while(res.x>TOLERANCE&&step<=MAXSTEP);

    
    return step<=MAXSTEP;
}


float procDepth(vec3 localPos){
    vec4 frag = gl_ModelViewProjectionMatrix*vec4(localPos,1);
    frag/=frag.w;
    return (frag.z+1)/2;
}


vec3 procNormal(vec3 marchpt)
{
    float dist = map(marchpt).x;

    return normalize(vec3(
        dist-map(marchpt-vec3(NORMALESP,0,0)).x,
        dist-map(marchpt-vec3(0,NORMALESP,0)).x,
        dist-map(marchpt-vec3(0,0,NORMALESP)).x
    ));
}

vec3 lightModel(vec3 eye,vec3 normal, vec3 light,float material){
	float NL = max(dot(normal,light),0);
	float RL = max(dot(eye,reflect(light,normal)),0);
	return vec3(material*0.2)+vec3(material)*NL+ vec3(material)*pow(RL,5);
}


void main(){
    vec2 uv = coord2uv(gl_FragCoord.xy);
    vec3 ro = cameraPos();
    vec3 rd = uv2ray(uv);

    vec3 nearest;
    float material;
      
    if(marching(ro,rd,nearest,material)){
		vec3 normal = procNormal(nearest);
        gl_FragDepth = procDepth(nearest);
        gl_FragColor = vec4(lightModel(rd,normal,lightPos(),material),1);
    }else{
       discard;
    }
}





 
 