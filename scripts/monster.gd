extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@onready var detection_range : float = 10.0

func _ready() -> void:
	add_to_group("monster")
	
	GSignals.make_noise.connect(_on_make_noise)
	
	navigation_agent_3d.path_desired_distance = 1.0
	
	navigation_agent_3d.target_desired_distance = 1.5 
	
	await get_tree().physics_frame
	_generate_position()

func _on_make_noise(noise: NoiseManager) -> void:
	if global_position.distance_to(noise.position) < detection_range * noise.intensity:
		navigation_agent_3d.target_position = noise.position
	else:
		pass

func _generate_position() -> void:
	var random_pos: Vector3 = Vector3.ZERO
	random_pos.x = randf_range(-15.0, 15.0)
	random_pos.y = global_position.y 
	random_pos.z = randf_range(-15.0, 15.0)
	
	navigation_agent_3d.target_position = random_pos
	print("Nouvelle position générée : ", random_pos)

func _physics_process(delta: float) -> void:
	if navigation_agent_3d.is_navigation_finished():
		return

	var destination: Vector3 = navigation_agent_3d.get_next_path_position()
	var direction: Vector3 = global_position.direction_to(destination)

	velocity.x = direction.x * 5.0
	velocity.z = direction.z * 5.0

	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	move_and_slide()

func _on_navigation_agent_3d_navigation_finished() -> void:
	_generate_position()
