extends CharacterBody3D

@export var speed: int = 14
@onready var body: CSGCylinder3D = $Body
@onready var sensivity: float = 0.002
@onready var camera: Camera3D = $Camera3D

var target_velocity: Vector3 = Vector3.ZERO
var camera_rotation_x: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensivity)
		camera_rotation_x -= event.relative.y * sensivity
		camera_rotation_x = clamp(camera_rotation_x, deg_to_rad(-89.0), deg_to_rad(89.0))
		camera.rotation.x = camera_rotation_x
		
		if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(_delta: float) -> void:
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var movement_dir: Vector3 = transform.basis * Vector3(input.x, 0, input.y)
		
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.z * speed
	
	move_and_slide()
