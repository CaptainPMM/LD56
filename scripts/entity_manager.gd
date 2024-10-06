extends Node

class_name entity_manager

@export var entity_scene: PackedScene
@export var laser_point: Node3D
@export var start_entities: Array[entity]

@onready var score_label: Label = %Score

var active_entities: Array[entity]
var current_count = 0

signal game_over

func _process(_delta: float) -> void:
	# all entities will follow the laser
	for _entity in active_entities:
		_entity.target_position = laser_point.global_position

func _on_entity_activated(_entity):
	if _entity.is_active:
		return
	active_entities.append(_entity)
	_entity.is_active = true
	_entity.freeze = false
	_entity.deactivated.connect(_on_entity_deactivated)
	current_count += 1
	score_label.text = str(current_count)
	#print("Score: " + str(current_count))

	for e in active_entities:
		if randf() < 0.66:
			e.cheer()
	
func _on_entity_deactivated(_entity):
	active_entities.erase(_entity)
	_entity.is_active = false
	current_count -= 1
	score_label.text = str(current_count)
	#print("Score: " + str(current_count))
	_entity.queue_free()
	
	if current_count == 0:
		game_over.emit()
	
	
func activate_start_entities():
	#print("often started?")
	for _entity in start_entities:
		_on_entity_activated(_entity)
	for _entity in get_tree().get_nodes_in_group("entity"):
		_entity.activated.connect(_on_entity_activated)
	
func instantiate_random():
	for i in range(50):
		var entity_instance = entity_scene.instantiate() 
		add_child(entity_instance)
		
		var random_x = randf_range(-4.0, 4.0)
		var random_z = randf_range(-4.0, 4.0)
		entity_instance.global_transform.origin = Vector3(random_x, 0, random_z)
	
