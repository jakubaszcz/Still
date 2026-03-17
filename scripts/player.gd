extends CharacterBody3D

@export var walk_speed: int = 3
@export var run_speed: int = 6

var is_running: bool = false
var can_run: bool = true

var stamina_timer: float = 0.0
var stamina_max: float = 3.0

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

@onready var footstep_sound: AudioStreamPlayer3D = $Footstep
@onready var background_music: AudioStreamPlayer3D = $AudioStreamPlayer3D

@onready var heartbeat_sound: AudioStreamPlayer3D = $Heartbeat
@onready var noise: FastNoiseLite = FastNoiseLite.new()

var monster : Node3D = null

var shake_intensity: float = 0.0
var shake_speed: float = 25.0
var noise_i: float = 0.0
var shake_tween: Tween

var left_hand_item : Item = null
var right_hand_item : Item = null


var target_velocity: Vector3 = Vector3.ZERO
var camera_rotation_x: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")
	noise.seed = randi()
	noise.frequency = 0.5

func _mouse_movement(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensivity)
		camera_rotation_x -= event.relative.y * sensivity
		camera_rotation_x = clamp(camera_rotation_x, deg_to_rad(-89.0), deg_to_rad(89.0))
		camera.rotation.x = camera_rotation_x

func _input(event):
	_mouse_movement(event)

func _make_noise():
	var intensity: float = 0.0
	var walk_intensity: float = 1.0
	var run_intensity: float = 3.0

	if can_run and is_running:
		intensity = run_intensity
	else:
		intensity = walk_intensity
	
	GSignals.make_noise.emit(NoiseManager.new(global_position, intensity))

func _movement():
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var movement_dir: Vector3 = transform.basis * Vector3(input.x, 0, input.y)
	var speed: float = walk_speed
	
	
	if Input.is_action_pressed("run") and can_run and input:
		footstep_sound.volume_db = 10.0
		footstep_sound.pitch_scale = 1.2
		speed = run_speed
		is_running = true
	else:
		footstep_sound.volume_db = -5.0
		footstep_sound.pitch_scale = 1.0
		is_running = false
		speed = walk_speed
	
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.z * speed
	
	if input:
		_make_noise()
		if not footstep_sound.is_playing():
			footstep_sound.play()
	else:
		if footstep_sound.is_playing():
			footstep_sound.stop()

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
	_update_monster_proximity(delta)
	_apply_shake(delta)
	
	if is_running:
		stamina_timer += delta
		if stamina_timer >= stamina_max:
			can_run = false
	else:
		stamina_timer -= delta
		if stamina_timer <= 0:
			stamina_timer = 0
			can_run = true
	
	stamina_timer = clamp(stamina_timer, 0.0, stamina_max)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()

func _apply_shake(delta: float):
	if shake_intensity > 0:
		noise_i += delta * shake_speed
		var shake_offset: Vector3 = Vector3(   
			noise.get_noise_1d(noise_i) * shake_intensity,
			noise.get_noise_1d(noise_i + 25) * shake_intensity,
			0.0
		)
		camera.h_offset = shake_offset.x
		camera.v_offset = shake_offset.y
	else:
		camera.h_offset = 0
		camera.v_offset = 0

func _update_monster_proximity(_delta: float):
	if monster:
		var distance: float = global_position.distance_to(monster.global_position)
		var max_distance: float = 13.0
		var proximity: float = 1.0 - clamp(distance / max_distance, 0.0, 1.0)
		
		shake_intensity = lerp(0.05, 0.4, proximity)
		shake_speed = lerp(15.0, 60.0, proximity)
		
		background_music.volume_db = lerp(-20.0, 10.0, proximity)
		
		heartbeat_sound.volume_db = lerp(-30.0, 15.0, proximity)
	else:
		pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("monster"):
		monster = body
		if not heartbeat_sound.playing:
			heartbeat_sound.play()
		if not background_music.playing:
			background_music.play()
		
		if shake_tween:
			shake_tween.kill()
		if background_music.get_meta("volume_tween", null):
			background_music.get_meta("volume_tween").kill()
			
		shake_tween = create_tween()
		# On commence doucement l'intensité, le reste est géré par la proximité
		shake_tween.tween_property(self, "shake_intensity", 0.05, 1.0)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("monster"):
		monster = null
		
		if shake_tween:
			shake_tween.kill()
		shake_tween = create_tween().set_parallel(true)
		shake_tween.tween_property(self, "shake_intensity", 0.0, 2.0)
		shake_tween.tween_property(background_music, "volume_db", -40.0, 3.0)
		shake_tween.tween_property(heartbeat_sound, "volume_db", -40.0, 2.0)
		
		shake_tween.finished.connect(func(): 
			if monster == null:
				heartbeat_sound.stop()
		)
