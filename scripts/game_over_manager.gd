class_name GameOverManager

enum GameOverState { LOSE, WIN }

var game_over_state: GameOverState

func _init(p_game_over_state: GameOverState) -> void:
	game_over_state = p_game_over_state
