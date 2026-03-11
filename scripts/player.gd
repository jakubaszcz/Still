extends CharacterBody3D

@export var speed: int = 14
@onready var body: CSGCylinder3D = $Body
@onready var sensivity: float = 0.002
@onready var camera: Camera3D = $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D


var target_velocity: Vector3 = Vector3.ZERO
var camera_rotation_x: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _mouse_movement(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensivity)
		camera_rotation_x -= event.relative.y * sensivity
		camera_rotation_x = clamp(camera_rotation_x, deg_to_rad(-89.0), deg_to_rad(89.0))
		camera.rotation.x = camera_rotation_x

func _input(event):
	_mouse_movement(event)

func _movement():
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var movement_dir: Vector3 = transform.basis * Vector3(input.x, 0, input.y)
		
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.z * speed

func _pick_item():
	if Input.is_action_just_pressed("left_hand") or Input.is_action_just_pressed("right_hand"):
		var item = _raycast_item()
		if item:
			item._drop()

func _raycast_item() -> Item:
	if ray.is_colliding():
		var hit: Object = ray.get_collider()
		if hit is Item:
			return hit
	return null

func _physics_process(_delta: float) -> void:
	
	_movement()
	_pick_item()
	
	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("monster"):
		print("Warning ! The monster has entered the zone.")


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("monster"):
		print("The monster has left the zone.")
