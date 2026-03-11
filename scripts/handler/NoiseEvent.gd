class_name NoiseEvent

enum NoiseType { FOOTSTEP }

var position: Vector3
var intensity: float
var type: NoiseType

func _init(p: Vector3, i: float, t: NoiseType):
	position = p
	intensity = i
	type = t