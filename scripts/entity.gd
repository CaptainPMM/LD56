extends RigidBody3D

class_name entity

# controlling
@export var attraction_strength = 10 
@export var damping_strength = 30    
@export var min_distance = 0.2      
@export var max_speed = 0.3        

# flocking
@export var separation_radius = 0.06       # Radius within which entities will try to separate
@export var alignment_radius = 0.5         # Radius within which entities will align their direction
@export var cohesion_radius = 7.0         # Radius within which entities will try to cohere
@export var separation_strength = 1.0     # Strength of the separation force
@export var alignment_strength = 1.0       # Strength of the alignment force
@export var cohesion_strength = 2.0        # Strength of the cohesion force

# sound
@export var footsteps : AudioStreamPlayer3D
@export var cheering : AudioStreamPlayer3D
var audio_timer = 0
var old_pos : Vector3

signal activated(entity)
signal deactivated(entity)

var is_active: bool # activated by entity_manager
var target_position = Vector3()
var log_timer = 0.0

func _init() -> void:
	self.add_to_group("entity")

func _ready():
	$Area3D.scale = Vector3(cohesion_radius, cohesion_radius, cohesion_radius)
	# freeze = true  # not sure if needed
	audio_timer = randi_range(0, 10)
	old_pos = global_position

func _physics_process(delta):
	if not is_active:
		return
		
	# flocking behavior
	var separation_force = calculate_separation_force()
	var alignment_force = calculate_alignment_force()
	var cohesion_force = calculate_cohesion_force()

	# calculate distance to target
	var flat_target_position = Vector3(target_position.x, global_transform.origin.y, target_position.z)
	var direction = flat_target_position - global_transform.origin
	var distance = direction.length()

	var attraction_force = Vector3.ZERO
	var damping_force = Vector3.ZERO
	
	# Only apply attraction if the entity is not already at the target
	if distance > min_distance:
		attraction_force = direction.normalized() * (attraction_strength * distance)

	# Calculate and apply a damping force to counteract the velocity if the entity is near the target
	if distance < min_distance:
		damping_force = -linear_velocity * damping_strength

	# Calculate the final force by combining flocking forces with attraction force
	var total_force = attraction_force + separation_force + alignment_force + cohesion_force
	apply_central_force(total_force)
	apply_central_force(damping_force)

	# Limit the speed to avoid instability or overshooting
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed

	# Increment the log timer and log every second
	log_timer += delta
	if log_timer >= 1.0:
		# Log the target position, entity position, distance, and total forces applied
		#print("Target Position (Y ignored): ", flat_target_position)
		#print("Entity Position: ", global_transform.origin)
		#print("Distance to Target: ", distance)
		#print("Total Attraction Force: ", attraction_force if distance > min_distance else Vector3(0, 0, 0))
		#print("Damping Force: ", damping_force)
		log_timer = 0.0 
		
	# Sound
	#if not OS.has_feature("web_android") and not OS.has_feature("web_ios"):
	var new_pos = global_position
	if audio_timer > 10:
		audio_timer = 0
		if (new_pos - old_pos).length() > 0.00175 and randf() < 0.75:
			if !footsteps.playing:
				footsteps.play()
	else:
		audio_timer += 1
	old_pos = new_pos

func cheer() -> void:
	#if not OS.has_feature("web_android") and not OS.has_feature("web_ios"):
	if !cheering.playing:
		cheering.play()

##################### FLOCKING HELPER FUNCTIONS ###############################

# Calculate the separation force to avoid overlapping with neighbors
func calculate_separation_force() -> Vector3:
	var separation_force = Vector3()
	var neighbors = get_neighbors(separation_radius)
	
	for neighbor in neighbors:
		var difference = global_transform.origin - neighbor.global_transform.origin
		var distance = difference.length()
		if distance > 0:  # Avoid division by zero
			separation_force += difference.normalized() / distance  # Inverse distance weighting
	
	return separation_force * separation_strength

# Calculate the alignment force to match velocity with nearby entities
func calculate_alignment_force() -> Vector3:
	var alignment_force = Vector3()
	var neighbors = get_neighbors(alignment_radius)
	
	if neighbors.size() > 0:
		var average_velocity = Vector3()
		for neighbor in neighbors:
			average_velocity += neighbor.linear_velocity
		average_velocity /= neighbors.size()
		alignment_force = (average_velocity - linear_velocity) * alignment_strength
	
	return alignment_force

# Calculate the cohesion force to steer towards the average position of nearby entities
func calculate_cohesion_force() -> Vector3:
	var cohesion_force = Vector3()
	var neighbors = get_neighbors(cohesion_radius)
	
	if neighbors.size() > 0:
		var average_position = Vector3()
		for neighbor in neighbors:
			average_position += neighbor.global_transform.origin
		average_position /= neighbors.size()
		cohesion_force = (average_position - global_transform.origin).normalized() * cohesion_strength
	
	return cohesion_force

func get_neighbors(radius: float) -> Array:
	var neighbors = []
	for e: entity in get_tree().get_nodes_in_group("entity"):
		if e != self:
			if global_transform.origin.distance_to(e.global_transform.origin) < radius:
				if e.is_active:
					neighbors.append(e)
	return neighbors


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is entity && body != self:
		if not is_active:
			emit_signal("activated", self)

func on_map_exited():
	if is_active:
		emit_signal("deactivated", self)
	else:
		queue_free()
