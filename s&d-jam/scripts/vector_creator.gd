extends Area2D

signal vector_creator(vector)

@export var max_lenght := 200

var touch_down := false
var pos_start := Vector2.ZERO
var pos_end := Vector2.ZERO

var vector := Vector2.ZERO


func _ready() -> void:
	connect("input_event", Callable(self, "_on_input_event"))


func _draw() -> void:
	# Convert world positions to local positions so the lines follow and rotate with the dice
	var local_start = to_local(pos_start)
	var local_end = to_local(pos_end)
	
	draw_line(local_start, local_end, Color.BLUE, 2)
	draw_line(local_start, local_start + vector, Color.RED, 3)


func _reset() -> void:
	pos_start = Vector2.ZERO
	pos_end = Vector2.ZERO
	vector = Vector2.ZERO
	queue_redraw()


func _input(event) -> void:
	if not touch_down:
		return
	
	if event.is_action_released("ui_touch"):
		touch_down = false
		emit_signal("vector_creator", vector)
		_reset()
	
	if event is InputEventMouseMotion:
		# Use get_global_mouse_position() to get correct world coordinates
		pos_end = pos_start + (get_global_mouse_position() - pos_start).limit_length(max_lenght)
		vector = -(pos_end - pos_start).limit_length(max_lenght)
		queue_redraw()


func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("ui_touch"):
		touch_down = true
		# Capture world position instead of raw screen pixels
		pos_start = get_global_mouse_position()
		pos_end = pos_start


func _process(_delta: float) -> void:
	# Force the area's rotation to always stay upright (0 degrees) globally
	global_rotation = 0.0
