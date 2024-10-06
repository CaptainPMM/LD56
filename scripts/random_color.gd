extends MeshInstance3D


@export_color_no_alpha var possible_colors: PackedColorArray = PackedColorArray()

func _ready() -> void:
	randomize() # Randomizes the seed (or the internal state) of the random number generator
	var color: Color = possible_colors[randi() % possible_colors.size()]
	
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.15
	self.material_override = mat
