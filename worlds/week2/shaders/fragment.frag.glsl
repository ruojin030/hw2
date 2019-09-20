#version 300 es        // NEWER VERSION OF GLSL
precision highp float; // HIGH PRECISION FLOATS

uniform float uTime;   // TIME, IN SECONDS
in vec3 vPos;          // POSITION IN IMAGE
out vec4 fragColor;    // RESULT WILL GO HERE
const int NS = 2; // Number of spheres in the scene
const int NL = 2; // Number of light sources in the scene
const float fl = 40.;
const vec3 E = vec3(0.,0.,1.); //10

// Declarations of arrays for spheres, lights and phong shading:

vec3 Ldir[NL], Lcol[NL], Ambient[NS], Diffuse[NS];
vec4 Sphere[NS], Specular[NS];

float raySphere(vec3 v, vec3 w, vec4 s){
    vec3 vv = v-s.xyz;
    float B = dot(w,vv);
    float C = dot(vv,vv)-s.w*s.w; //20
    if((B*B-C)<0.){
        return -1.;
    } 
    return -B-sqrt(B*B-C);
}
bool isInShadow(vec3 P, vec3 L, vec4 Sphere[NS]){ // is point P in shadow from light L?
    for(int i = 0;i<NS;i++){
        if(raySphere(P,L,Sphere[i])>0.0001){
            return true;
        }//30
    }
    return false;
}
void main() {

    Ldir[0] = normalize(vec3(20.,10.,10));
    Lcol[0] = vec3(.5,.3,.5);

    Ldir[1] = normalize(vec3(-5.,-5.,-5.));
    Lcol[1] = vec3(.2,.3,0.5); //40

    Sphere[0]   = vec4(0.,0.0,0,0.4);
    Ambient[0]  = vec3(0.1,.1,.1);
    Diffuse[0]  = vec3(0.5,.5,.5);
    Specular[0] = vec4(.6,.6,.6,10.); // 4th value is specular power

    Sphere[1]   = vec4(0.0,.65,0,0.3);
    Ambient[1]  = vec3(.1,.1,0.1);
    Diffuse[1]  = vec3(.5,.5,0.5);
    Specular[1] = vec4(1.,1.,1.,20.); // 4th value is specular power //50
 

    vec3 v = vec3(0,0,fl);
    vec3 w = normalize(vec3(vPos.xy,-fl));
    float tMin = 100.;
    int pos = -1;
    for(int i = 0;i<NS;i++){
        float t = raySphere(v,w,Sphere[i]);
        if(t>0. && t<tMin){
            tMin = t; //60
            pos = i;
        }
    }
    vec3 color = vec3(0,0,0);
    if(pos != -1){
        vec3 P = v+tMin*w;
        vec3 N = normalize(P-Sphere[pos].xyz);
        color = Ambient[pos]; //original color
        for(int i = 0;i<NL;i++){
            if(!isInShadow(P,Ldir[i],Sphere)){ // if not is shadow//70
                color+= Lcol[i]*Diffuse[pos]*max(0.,dot(N,Ldir[i]));
                vec3 R = 2.*dot(N,Ldir[i])*N-Ldir[i];
                color+= Lcol[i]*Specular[pos].xyz*pow(max(0.,dot(E,R)),Specular[pos].w);
                        
            }         
        }
    }
    fragColor = vec4(sqrt(color), 1.0);

  

}

