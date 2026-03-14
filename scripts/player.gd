extends CharacterBody3D

@export var speed: int = 14
@onready var body: CSGCylinder3D = $Body
@onready var sensivity: float = 0.002
@onready var camera: Camera3D = $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D

enum HandState { HOLD, EMPTY }
enum HandType { LEFT, RIGHT }

@onready var left_hand_position : Vector3 = Vector3(-1.0, -0.5, -1)
@onready var left_hand_state : HandState = HandState.EMPTY
@onready var right_hand_position : Vector3 = Vector3(1.0, -0.5, -1)
@onready var right_hand_state : HandState = HandState.EMPTY

var left_hand_item : Item = null
var right_hand_item : Item = null

var target_velocity: Vector3 = Vector3.ZERO
var camera_rotation_x: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")

func _mouse_movement(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensivity)
		camera_rotation_x -= event.relative.y * sensivity
		camera_rotation_x = clamp(camera_rotation_x, deg_to_rad(-89.0), deg_to_rad(89.0))
		camera.rotation.x = camera_rotation_x

func _input(event):
	_mouse_movement(event)

func _make_noise():
	GSignals.make_noise.emit(NoiseManager.new(global_position, 0.6))

func _movement():
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var movement_dir: Vector3 = transform.basis * Vector3(input.x, 0, input.y)
		
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.z * speed
	
	if input:
		_make_noise()


func _pick_item():
	if Input.is_action_just_pressed("left_hand") or Input.is_action_just_pressed("right_hand"):
		var item: Object = _raycast_item()
		if Input.is_action_just_pressed("left_hand"):
			if item is Item or item == null:
				_hand(HandType.LEFT, item)
			elif item and item.is_in_group("door"):
				if left_hand_item and left_hand_item.item_name == Item.ItemType.KEY:
					item._door()
				else:
					item._door_locked()
		elif Input.is_action_just_pressed("right_hand"):
			if item is Item or item == null:
				_hand(HandType.RIGHT, item)
			elif item and item.is_in_group("door"):
				if right_hand_item and right_hand_item.item_name == Item.ItemType.KEY:
					item._door()
				else:
					item._door_locked()

func _hand(hand : HandType, item : Item):
		match hand:
			HandType.LEFT:
				_left_hand(item)
			HandType.RIGHT:
				_right_hand(item)

func _left_hand(item : Item):
	match left_hand_state:
		HandState.HOLD:
			if left_hand_item:
				left_hand_item._drop(global_position + Vector3(0, 1, -1).rotated(Vector3.UP, rotation.y))
				left_hand_item = null
				left_hand_state = HandState.EMPTY
		HandState.EMPTY:
			if item:
				left_hand_item = item
				left_hand_item._hold(body, left_hand_position)
				left_hand_state = HandState.HOLD

func _right_hand(item : Item):
	match right_hand_state:
		HandState.HOLD:
			if right_hand_item:
				right_hand_item._drop(global_position + Vector3(0, 1, -1).rotated(Vector3.UP, rotation.y))
				right_hand_item = null
				right_hand_state = HandState.EMPTY
		HandState.EMPTY:
			if item:
				right_hand_item = item
				right_hand_item._hold(body, right_hand_position)
				right_hand_state = HandState.HOLD
	


func _raycast_item() -> Object:
	if ray.is_colliding():
		var hit: Object = ray.get_collider()
		if hit is Item:
			return hit
		if hit.is_in_group("door"):
			return hit
	return null

func _physics_process(delta: float) -> void:
	
	_movement()
	_pick_item()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()
