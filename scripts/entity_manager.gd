extends Node

class_name entity_manager

@export var entity_scene: PackedScene
@export var laser_point: Node3D
@export var entity_count: int = 50
@export var start_entities: Array[entity]

var active_entities: Array[entity]

func _process(delta: float) -> void:
	# all entities will follow the laser
	for entity in active_entities:
		entity.target_position = laser_point.position

func _on_entity_activated(entity):
	active_entities.append(entity)
	entity.is_active = true
	
func activate_start_entities():
	active_entities = start_entities
	for entity in active_entities:
		entity.is_active = true
	for entity in get_tree().get_nodes_in_group("entity"):
		entity.activated.connect(_on_entity_activated)
	
func instantiate_random():
	for i in range(entity_count):
		var entity_instance = entity_scene.instantiate() 
		add_child(entity_instance)
		
		var random_x = randf_range(-4.0, 4.0)
		var random_z = randf_range(-4.0, 4.0)
		entity_instance.global_transform.origin = Vector3(random_x, 0, random_z)
	
