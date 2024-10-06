extends Node
class_name GameManager

@export var _cam : Camera
@export var _entity_manager : entity_manager

@onready var start_screen: Panel = %Start_screen
@onready var game_over_screen: Panel = %GameOver_screen
@onready var win_screen: Panel = %Win_screen
@onready var win_text: Label = %Win_text

var _initCamSpeed : float
var _isGameStarted : bool
var _allDudesCount
var _destinationCount = 0

func _ready() -> void:
	_initCamSpeed = _cam.getXMovSpeed()
	_cam.setXMovSpeed(0)
	_cam.setMouseInputs(false)
	_allDudesCount = getDudeCount()

# ONLY FOR TESTING: should be moved to a UI controller or similar that calls startGame from there on space press
func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		# wait one frame before starting the game, because otherwise every dude on the map
		# will instantly run to the mouse cursor
		await get_tree().process_frame
		startGame()

func startGame() -> void:
	if !_isGameStarted:
		# hide mouse cursor
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		
		_cam.setXMovSpeed(_initCamSpeed)
		_cam.setMouseInputs(true)
		_entity_manager.activate_start_entities()
		_entity_manager.connect("game_over", _on_game_over)
		start_screen.visible = false
		_isGameStarted = true
		
	elif game_over_screen.visible or win_screen.visible:
		get_tree().reload_current_scene()
	
func getDudeCount() -> int:
	return get_tree().get_nodes_in_group("entity").size() # not a very good implementation
	
func _on_game_over():
	_cam.setXMovSpeed(0)
	game_over_screen.visible = true


func _on_destination_body_entered(body: Node3D) -> void:
	if body is entity:
		_destinationCount += 1
		if _destinationCount == _entity_manager.active_entities.size():
			_cam.setXMovSpeed(0)
			_entity_manager.active_entities.clear()
			win_text.text = "Congratulations! \nYou collected " + str(_entity_manager.current_count) + " from " + str(_allDudesCount) + " Dudes! \nPress 'Space' to try again." 
			win_screen.visible = true
			
