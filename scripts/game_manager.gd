extends Node
class_name GameManager

@export var _cam : Camera
@export var _entity_manager : entity_manager

var _initCamSpeed : float
var _isGameStarted : bool

func _ready() -> void:
	_initCamSpeed = _cam.getXMovSpeed()
	_cam.setXMovSpeed(0)
	_cam.setMouseInputs(false)

# ONLY FOR TESTING: should be moved to a UI controller or similar that calls startGame from there on space press
func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		startGame()

func startGame() -> void:
	if !_isGameStarted:
		_cam.setXMovSpeed(_initCamSpeed)
		_cam.setMouseInputs(true)
		_entity_manager.activate_start_entities()
		_isGameStarted = true
	
func getDudeCount() -> int:
	return get_tree().get_nodes_in_group("entity").size() # not a very good implementation
