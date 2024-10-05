extends Node

class_name entity_manager

@export var entity_scene: PackedScene
@export var laser_point: Node3D
@export var start_entities: Array[entity]

var active_entities: Array[entity]
var current_count = 0

func _process(delta: float) -> void:
	# all entities will follow the laser
	for entity in active_entities:
		entity.target_position = laser_point.position

func _on_entity_activated(entity):
	active_entities.append(entity)
	entity.is_active = true
	entity.deactivated.connect(_on_entity_deactivated)
	current_count += 1
	print("Score: " + str(current_count))
	
func _on_entity_deactivated(entity):
	active_entities.erase(entity)
	entity.is_active = false
	current_count -= 1
	print("Score: " + str(current_count))
	
func activate_start_entities():
	for entity in start_entities:
		_on_entity_activated(entity)
	for entity in get_tree().get_nodes_in_group("entity"):
		entity.activated.connect(_on_entity_activated)
	
func instantiate_random():
	for i in range(50):
		var entity_instance = entity_scene.instantiate() 
		add_child(entity_instance)
		
		var random_x = randf_range(-4.0, 4.0)
		var random_z = randf_range(-4.0, 4.0)
		entity_instance.global_transform.origin = Vector3(random_x, 0, random_z)
	
