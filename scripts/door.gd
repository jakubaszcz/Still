extends CharacterBody3D

@onready var door_locked_sound: AudioStreamPlayer3D = $Door_Locked
@onready var door_unlocked_sound: AudioStreamPlayer3D = $Door_Unlocked

func _ready() -> void:
	add_to_group("door")

func _door_locked() -> void:
	door_locked_sound.play()

func _door() -> void:
	door_unlocked_sound.play()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()