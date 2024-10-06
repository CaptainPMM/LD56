extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var randomVal = rng.randi_range(0, 25)
	var num = 65 + randomVal;
	
	
	$S1.text = String.chr(num);
	$S2.text = String.chr(num);
	$S3.text = String.chr(num);
	$S4.text = String.chr(num);
	$S5.text = String.chr(num);
	$S6.text = String.chr(num);
	
	var old_mat = $Cube.mesh.surface_get_material(1).duplicate();
	old_mat.albedo_color = Color(rng.randi_range(1, 4) / 4.0, rng.randi_range(1, 4) / 4.0, rng.randi_range(1, 4) / 4.0)
	
	$Cube.set_surface_override_material(1, old_mat);
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr
