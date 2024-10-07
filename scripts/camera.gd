extends Node3D
class_name Camera

@export var _xMovSpeed : float = 0.2
@export var _floorCollMask : int = 1 << 1 # layer 2
@export var _railsCollMask : int = 1 << 2 # layer 3
@export var _laserPoint : Node3D
@export_flags_3d_physics var _collisionMask : int

@onready var _cam : Camera3D = $Camera3D
@onready var _pointer_line : Node3D = $PointerLine

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
		var rayQuery = PhysicsRayQueryParameters3D.create(from, to, _collisionMask);
		rayQuery.collide_with_areas = true;
		var rayResult = castSpace.intersect_ray(rayQuery);
		
		if rayResult:
			var direction = (from - to).normalized()
			direction.y -= 0.1
			var la_basis = Basis.looking_at(direction)
			# visualization dot on surface
			_laserPoint.position = rayResult.position;
			_laserPoint.global_transform.basis = la_basis
			# visualization with line
			_pointer_line.global_position = rayResult.position
			_pointer_line.global_transform.basis = la_basis

func getXMovSpeed() -> float:
	return _xMovSpeed
	
func setXMovSpeed(speed: float) -> void:
	_xMovSpeed = speed

func getMouseInputs() -> bool:
	return _mouseInputs

func setMouseInputs(enabled: bool) -> void:
	_mouseInputs = enabled

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is entity:
		body.on_map_exited()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is roomba:
		body.is_activated = true
