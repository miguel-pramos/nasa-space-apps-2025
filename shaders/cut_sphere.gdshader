shader_type spatial; 

#include "funcs.gdshaderinc"
uniform vec3 spherePos; //Sphere position
uniform vec3 borderColor: source_color; 
uniform float borderSize; 
uniform float sphereRadius; 

// Realtime Simplex Noise
uniform float noiseSpeed; 
uniform float noiseStrength; 
uniform float noiseSize; 

uniform sampler2D _albedo: source_color; 
varying vec3 wVex; 

void vertex(){
	// World space coordinates
	wVex = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; 
}

void fragment(){
	
	// position relative to 3d space
	vec3 p = wVex-spherePos; 
	// SDF function
	float sdfSphere = sdSphere(p,sphereRadius); 
	// Noise parameters
	sdfSphere += snoise(p*noiseSize+TIME*noiseSpeed)*noiseStrength; 
	// Border
	float borderDist = smoothstep(0.0,borderSize,sdfSphere); 
	// Cut the sphere using SDF
	if (sdfSphere < 0.0) discard; 
	vec3 albColor = texture(_albedo,UV).rgb; 
	vec3 bcol = borderColor; 
	ALBEDO = (mix(bcol,albColor,borderDist)); 
	EMISSION = (mix(bcol *7.0,vec3(0.0),borderDist)); 
}