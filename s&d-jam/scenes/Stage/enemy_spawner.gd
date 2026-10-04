extends Node2D

@export_category("Enemy Prefabs")
@export var ground_enemy_scene: PackedScene
@export var flying_enemy_scene: PackedScene

@export_category("Wave Configuration")
@export var wave_delay: float = 3.0
@export var spawn_interval: float = 1.0

# Define what each wave contains
@export var waves: Array[Dictionary] = [
	{"ground": 5, "flying": 2}, # Wave 1
	{"ground": 8, "flying": 5}, # Wave 2
	{"ground": 12, "flying": 10} # Wave 3
]

var current_wave_index: int = 0
var active_enemies: int = 0
var pending_ground: int = 0
var pending_flying: int = 0

@onready var ground_markers: Array = $GroundSpawnPoints.get_children()
@onready var air_markers: Array = $AirSpawnPoints.get_children()
@onready var timer: Timer = $SpawnTimer

func _ready() -> void:
	timer.timeout.connect(_on_spawn_timer_timeout)
	start_next_wave()

func start_next_wave() -> void:
	if current_wave_index >= waves.size():
		print("All waves completed!")
		return
		
	var wave_data = waves[current_wave_index]
	pending_ground = wave_data.get("ground", 0)
	pending_flying = wave_data.get("flying", 0)
	
	print("Starting Wave %d" % (current_wave_index + 1))
	timer.start(spawn_interval)

func _on_spawn_timer_timeout() -> void:
	# Check if we still have enemies to spawn this wave
	if pending_ground > 0 or pending_flying > 0:
		# Decide which enemy type to spawn based on remaining counts
		var spawn_ground = false
		if pending_ground > 0 and pending_flying > 0:
			spawn_ground = randf() > 0.5
		elif pending_ground > 0:
			spawn_ground = true
			
		if spawn_ground:
			spawn_enemy(ground_enemy_scene, ground_markers)
			pending_ground -= 1
		else:
			spawn_enemy(flying_enemy_scene, air_markers)
			pending_flying -= 1
	else:
		timer.stop() # Finished spawning this wave's enemies

func spawn_enemy(enemy_scene: PackedScene, marker_list: Array) -> void:
	if enemy_scene == null or marker_list.is_empty():
		return
		
	var spawn_point: Marker2D = marker_list.pick_random() as Marker2D
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_point.global_position
	
	# Check if the spawn marker has a child named "PatrolPoints"
	if spawn_point.has_node("PatrolPoints"):
		enemy.patrol_points = spawn_point.get_node("PatrolPoints")
	
	enemy.tree_exited.connect(_on_enemy_destroyed)
	
	# add_child fires enemy._ready(), so patrol_points must be set before this step
	get_parent().add_child(enemy)
	active_enemies += 1

func _on_enemy_destroyed() -> void:
	active_enemies -= 1
	
	if not is_inside_tree():
		return
	# If all spawned enemies are dead and no more are pending, start next wave
	if active_enemies <= 0 and pending_ground == 0 and pending_flying == 0:
		current_wave_index += 1
		timer.start(wave_delay)
