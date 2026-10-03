extends RigidBody2D

@export var multiply = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func launch(force: Vector2) -> void:
	# Force wake up the physics body
	sleeping = false
	
	# Apply impulse directly using the physics server or standard call with explicit values
	apply_central_impulse(force * multiply) # Multiply to ensure it's not just too weak to see
	print("Impulse applied with force: ", force * multiply)
