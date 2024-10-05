extends Node3D
class_name Furball


@export_group("Setup")
@export var shell_mesh: Mesh
@export var shell_material: ShaderMaterial
@export var shell_scene: PackedScene

@export_category("Shells")
@export var shell_count: int = 16
@export_category("Fur")
@export_range(1, 1000) var density: float = 100
@export_range(0, 1) var length: float = 0.15
@export_range(0, 10) var thickness: float = 5
@export_range(0, 3) var distance_attenuation: float = 1
@export_range(0, 1) var noise_min: float = 0
@export_range(0, 1) var noise_max: float = 1
@export_color_no_alpha var color: Color
@export_category("Lighting")
@export_range(0, 5) var occlusion_attenuation: float = 1
@export_range(0, 1) var occlusion_bias: float = 0
@export_category("Physics")
@export_range(0, 10) var curvature: float = 1
@export_range(0, 1) var displacement_strength: float = 0.1

var displacement_vector: Vector3 = Vector3.ZERO

func _ready() -> void:
	$Preview.visible = false
	for i in shell_count:
		var shell: Shell = shell_scene.instantiate()
		$Shells.add_child(shell)
		shell.name = str("Shell ", i)
		shell.mesh_instance.mesh = shell_mesh
		var mat_duplicate: ShaderMaterial = shell_material.duplicate()
		update_properties_material(mat_duplicate, i)
		shell.mesh_instance.material_override = mat_duplicate

func _process(_delta: float) -> void:
	# update all shader globals every frame in editor or debug build, but not in release build
	if OS.has_feature("debug"):
		update_properties_all_materials()

@onready var old_pos: Vector3 = self.global_position

func _physics_process(delta: float) -> void:
	var pos_change = self.global_position - old_pos
	old_pos = self.global_position
	
	var glob_scale = self.global_transform.basis.get_scale()
	displacement_vector -= pos_change * 3 / glob_scale
	displacement_vector.y -= delta * 10
	
	var len: float = 3
	if (displacement_vector.length() > len):
		displacement_vector = displacement_vector.normalized() * len
	update_physics_all_materials()

func update_physics_all_materials() -> void:
	var children: Array[Node] = $Shells.get_children()
	for i in children.size():
		var shell: Shell = children[i]
		var mat: ShaderMaterial = shell.mesh_instance.material_override
		var glob_scale = self.global_transform.basis.get_scale()
		# quick hack: make vertical movement more visible
		mat.set_shader_parameter(
			"u_displacement_vector",
			displacement_vector * glob_scale * Vector3(1,0.5,1)
		)

func update_properties_all_materials() -> void:
	var children: Array[Node] = $Shells.get_children()
	for i in children.size():
		var shell: Shell = children[i]
		update_properties_material(shell.mesh_instance.material_override, i)

func update_properties_material(mat: ShaderMaterial, shell_index: int) -> void:
	mat.set_shader_parameter("u_shell_index", shell_index)
	mat.set_shader_parameter("u_shell_count", shell_count)
	mat.set_shader_parameter("u_density", density)
	mat.set_shader_parameter("u_length", length)
	mat.set_shader_parameter("u_thickness", thickness)
	mat.set_shader_parameter("u_curvature", curvature)
	mat.set_shader_parameter("u_distance_attenuation", distance_attenuation)
	mat.set_shader_parameter("u_noise_min", noise_min)
	mat.set_shader_parameter("u_noise_max", noise_max)
	mat.set_shader_parameter("u_color", color)
	mat.set_shader_parameter("u_occlusion_attenuation", occlusion_attenuation)
	mat.set_shader_parameter("u_occlusion_bias", occlusion_bias)
	mat.set_shader_parameter("u_displacement_strength", displacement_strength)
