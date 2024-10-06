shader_type spatial;
uniform vec3 input_color1 : source_color;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = input_color1 * max(0.73, min(.75, (sin(UV.x * 1000.0) + 1.0) / 2.0));
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
