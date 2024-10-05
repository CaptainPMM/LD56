extends Node3D


var last_dir: Vector3

func _process(delta: float) -> void:
	var glob_scale = self.global_transform.basis.get_scale()
	var vel = $"..".linear_velocity
	var gs = Basis.from_scale(glob_scale)
	var dir = lerp(last_dir, -vel, delta * 5.0)
	last_dir = dir
	if abs(dir.x) > 0.00001 && abs(dir.z) > 0.00001:
		self.global_transform.basis = Basis.looking_at(dir) * gs
