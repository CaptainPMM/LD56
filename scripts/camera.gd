extends Node3D
class_name Camera

@export var _xMovSpeed : float = 0.2
@export var _railsCollMask : int = 2

@onready var _cam : Camera3D = $Camera3D

func _ready() -> void:
	_positionCam()

func _process(delta: float) -> void:
	position.x += _xMovSpeed * delta
	_positionCam()
	
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

func getXMovSpeed() -> float:
	return _xMovSpeed
	
func setXMovSpeed(speed: float) -> void:
	_xMovSpeed = speed
