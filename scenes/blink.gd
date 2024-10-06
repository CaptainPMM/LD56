extends Node


var target : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_parent()
	target.pivot_offset = target.size / 2
	scale()
	
func scale():
	add_tween("scale", Vector2(1.3,1.3), 0.3)
	await get_tree().create_timer(0.5).timeout
	add_tween("scale", Vector2(1,1), 0.3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func add_tween(property: String, value, seconds: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(target, property, value, seconds).set_trans(Tween.TRANS_LINEAR)
