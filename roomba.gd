extends RigidBody3D

class_name roomba

@export var speed = 1.0
@export var point_a : Node3D 
@export var point_b : Node3D
@export var steering_strength = 30.0
@export var braking_factor = 0.8
@export var rotation_speed = 5.0
@export var sucking_strength = 5

var position_a
var position_b 

var target_position = Vector3()
var target_rotation_y
var sucked_entities : Array[entity]
var is_activated: bool

func _ready():
	position_a = Vector3(point_a.global_transform.origin.x, global_transform.origin.y, point_a.global_transform.origin.z )
	position_b = Vector3(point_b.global_transform.origin.x, global_transform.origin.y, point_b.global_transform.origin.z )
	
	target_position = position_b
	target_rotation_y = PI

func _physics_process(_delta : float):
	if !is_activated:
		return
	
	var direction_vector = (target_position - global_transform.origin).normalized()
	direction_vector.y = 0

	var desired_velocity = direction_vector * speed
	var steering_force = (desired_velocity - linear_velocity) * steering_strength
	apply_central_force(steering_force)

	var brake_force = -linear_velocity * (1.0 - braking_factor)
	apply_central_force(brake_force)
	
	for e in sucked_entities:
		sucking_entity(e)

	if is_target_reached():
		rotate_and_turn()


func is_target_reached() -> bool:
	return global_transform.origin.distance_to(target_position) < 0.1

func change_direction():
	if target_position == position_b:
		target_position = position_a
		target_rotation_y -= PI
	else:
		target_position = position_b
		target_rotation_y += PI

func rotate_and_turn():
	var current_rotation_y = self.rotation.y
	var new_rotation_y = lerp_angle(current_rotation_y, target_rotation_y, rotation_speed * get_process_delta_time())
	self.rotation.y = new_rotation_y
	
	if abs(abs(current_rotation_y) - abs(target_rotation_y)) < 0.05:
		change_direction()


func _on_sucking_area_body_entered(body: Node3D) -> void:
	if body is entity:
		sucked_entities.append(body)
		

func _on_kill_area_body_entered(body: Node3D) -> void:
	if body is entity:
		sucked_entities.erase(body)
		body.on_map_exited()
		

func sucking_entity(e):
	if e == null: # maybe it died anoutehr way
		sucked_entities.erase(e)
		return
	var direction = global_transform.origin - e.global_transform.origin
	var distance = direction.length()
	var force = direction.normalized() * sucking_strength / distance
	e.apply_central_force(force)


func _on_sucking_area_body_exited(body: Node3D) -> void:
	if body is entity:
		sucked_entities.erase(body)
		
