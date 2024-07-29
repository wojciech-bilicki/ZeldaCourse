extends Node

@onready var player: Player = $Player
@onready var player_spawn_point: Marker2D = $PlayerSpawnPoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		TransitionChangeManager.transition_done.connect(on_transition_done)
		player.position = player_spawn_point.position
		if TransitionChangeManager.is_transitioning:
			player.set_process_input(false)
			player.set_physics_process(false)

func on_transition_done():
	player.set_process_input(true)
	player.set_physics_process(true)
