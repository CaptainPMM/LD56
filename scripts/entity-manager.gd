extends Node

@export var entity_scene: PackedScene
@export var entity_count: int = 50

func _ready():
	instantiate_random()
		

func instantiate_random():
	for i in range(entity_count):
		var entity_instance = entity_scene.instantiate() 
		add_child(entity_instance)
		
		var random_x = randf_range(-4.0, 4.0)
		var random_z = randf_range(-4.0, 4.0)
		entity_instance.global_transform.origin = Vector3(random_x, 0, random_z)
	
