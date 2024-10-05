shader_type spatial;
render_mode cull_disabled;
//render_mode unshaded; // for testing
render_mode skip_vertex_transform;

// shells
uniform int u_shell_index;
uniform int u_shell_count;
// fur
uniform float u_density;
uniform float u_length;
uniform float u_thickness;
uniform float u_distance_attenuation;
uniform float u_noise_min;
uniform float u_noise_max;
uniform vec3 u_color;
// lighting
uniform float u_occlusion_attenuation;
uniform float u_occlusion_bias;
// physics
uniform float u_curvature;
uniform float u_displacement_strength;
uniform vec3 u_displacement_vector; // updated on CPU to match movement

varying vec3 v_debug;
varying float v_ambient_occlusion;

void vertex() {
	float height_normalized = float(u_shell_index) / float(u_shell_count); // [0;1]

	vec3 height_offset = pow(height_normalized, u_distance_attenuation) * u_length * NORMAL;
	float k = pow(height_normalized, u_curvature);
	vec3 physics_offset = k * u_displacement_strength * u_displacement_vector;
	
	VERTEX += height_offset;
	
    VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    BINORMAL = normalize((MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz);
    TANGENT = normalize((MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz);
	
	VERTEX += physics_offset;
}

float hash(uint n) {
	// integer hash copied from Hugo Elias
	n = (n << 13U) ^ n;

	// not entirely sure if this line is converted correctly
	//n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
	n = n * (n * n * 15731U + 7901729U) + 83587310985U;

	return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
}

void fragment() {
	vec2 scaled_uv = UV * u_density;
	vec2 local_uv_centered = fract(scaled_uv) * 2.0 - 1.0;
	float local_center_distance = length(local_uv_centered);

	uvec2 tid = uvec2(scaled_uv);
	uint seed = tid.x + uint(100) * tid.y + uint(100) * uint(10);
	float rand = mix(u_noise_min, u_noise_max, hash(seed));

	float height_normalized = float(u_shell_index) / float(u_shell_count); // [0;1]

	bool clip = local_center_distance > u_thickness * (rand - height_normalized);

	// always draw the inner shell
	if (clip && u_shell_index > 0) discard;

	v_ambient_occlusion = pow(height_normalized, u_occlusion_attenuation) + u_occlusion_bias;
	v_ambient_occlusion = clamp(v_ambient_occlusion, 0, 1);

	ALBEDO = vec3(u_color);
}

void light() {
	float n_dot_l = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float lighting = n_dot_l * 0.5 + 0.5;
	lighting = lighting * lighting;
	DIFFUSE_LIGHT += lighting * ATTENUATION * v_ambient_occlusion * LIGHT_COLOR;
}
