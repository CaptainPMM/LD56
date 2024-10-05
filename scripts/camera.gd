extends Node3D
class_name Camera

@export var _xMovSpeed : float = 0.2
@export var _floorCollMask : int = 1 << 1 # layer 2
@export var _railsCollMask : int = 1 << 2 # layer 3
@export var _laserPoint : Node3D

@onready var _cam : Camera3D = $Camera3D

var _mouseInputs : bool = true

func _ready() -> void:
	_positionCam()

func _process(delta: float) -> void:
	position.x += _xMovSpeed * delta
	_positionCam()
	_handleLaser()
	
func _physics_process(_delta: float) -> void:
	var origin = global_position + Vector3(0, 100, 0)
	var ray = PhysicsRayQueryParameters3D.create(origin, global_position + Vector3.DOWN, _railsCollMask)
	var spaceState = get_world_3d().direct_space_state
	var result = spaceState.intersect_ray(ray)
	if result:
		position.y = max(0, result.position.y)
	else:
		position.y = 0
	
func _positionCam() -> void:
	_cam.look_at(position)
	
func _handleLaser() -> void:
	if _mouseInputs:
		var mousePos = get_viewport().get_mouse_position();
		var maxDist = 100;
		var from = get_viewport().get_camera_3d().project_ray_origin(mousePos);
		var to = from + get_viewport().get_camera_3d().project_ray_normal(mousePos) * maxDist;
		var castSpace  = get_viewport().world_3d.direct_space_state;
		var rayQuery = PhysicsRayQueryParameters3D.create(from, to, _floorCollMask);
		rayQuery.collide_with_areas = true;
		var rayResult = castSpace.intersect_ray(rayQuery);
		
		if rayResult:
			_laserPoint.position = rayResult.position;
	
	# all entities will follow the laser
	for entity in get_tree().get_nodes_in_group("entity"):
		entity.target_position = _laserPoint.position

func getXMovSpeed() -> float:
	return _xMovSpeed
	
func setXMovSpeed(speed: float) -> void:
	_xMovSpeed = speed

func getMouseInputs() -> bool:
	return _mouseInputs

func setMouseInputs(enabled: bool) -> void:
	_mouseInputs = enabled
