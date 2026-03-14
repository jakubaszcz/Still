extends Node

@onready var death_sound : AudioStreamPlayer3D = $Death

func _ready() -> void:
	GSignals.game_over.connect(_on_game_over)

func _on_game_over(game_over_manager: GameOverManager) -> void:
	if game_over_manager.game_over_state == GameOverManager.GameOverState.LOSE:
		death_sound.play()
		await get_tree().create_timer(0.5).timeout
		get_tree().reload_current_scene()
		
