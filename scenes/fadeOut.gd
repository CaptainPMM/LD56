class_name FadeOut_Controller extends Node


var target : Control
var blink_target : Control

var is_visible : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_parent()
	blink_target = get_child(0)
	target.pivot_offset = target.size / 2
	blink_target.pivot_offset = blink_target.size / 2
	is_visible = true
	blink()
	
	
func fade_out():
	add_tween("modulate:a", 0.0, 0.4, target)
	await get_tree().create_timer(0.4).timeout
	target.visible = false
	blink_target.visible = false
	is_visible = false

func blink():
	while is_visible:
		add_tween("modulate:a", 0.5, 0.7, blink_target)
		await get_tree().create_timer(0.7).timeout
		add_tween("modulate:a", 1.0, 0.7, blink_target)
		await get_tree().create_timer(1).timeout
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func add_tween(property: String, value, seconds: float, tween_target) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(tween_target, property, value, seconds).set_trans(Tween.TRANS_LINEAR)
