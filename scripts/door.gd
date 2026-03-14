extends CharacterBody3D

func _ready() -> void:
	add_to_group("door")

func _door() -> void:
	print("Door has been opened")
