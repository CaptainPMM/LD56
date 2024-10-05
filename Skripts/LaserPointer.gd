extends Node

@export var laserPunkt : Node3D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mousePos = get_viewport().get_mouse_position();
	var maxDist = 100;
	var from = get_viewport().get_camera_3d().project_ray_origin(mousePos);
	var to = from + get_viewport().get_camera_3d().project_ray_normal(mousePos) * maxDist;
	var  castSpace  = get_viewport().world_3d.direct_space_state;
	var rayQuery = PhysicsRayQueryParameters3D.create(from, to);
	rayQuery.collide_with_areas = true;
	var rayResult = castSpace.intersect_ray(rayQuery);
	
	if rayResult:
		laserPunkt.position = rayResult.position;
		
	
	# all entities will follow the laser
	for entity in get_tree().get_nodes_in_group("entity"):
		entity.target_position = laserPunkt.position
