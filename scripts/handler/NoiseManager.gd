extends Node

signal noise_detected(event: NoiseEvent)

func _ready():
	NoiseManager.noise_detected.connect(_on_noise_detected)

func _on_noise_detected(event : NoiseEvent):
	print(str(event.intensity) + "," + str(event.NoiseType) + "," + str(event.position))