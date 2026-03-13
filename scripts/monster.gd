extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	add_to_group("monster")
	
	navigation_agent_3d.path_desired_distance = 1.0
	
	navigation_agent_3d.target_desired_distance = 1.5 
	
	await get_tree().physics_frame
	_generate_position()

func _generate_position() -> void:
	var random_pos = Vector3.ZERO
	random_pos.x = randf_range(-15.0, 15.0)
	random_pos.y = global_position.y 
	random_pos.z = randf_range(-15.0, 15.0)
	
	navigation_agent_3d.target_position = random_pos
	print("Nouvelle position générée : ", random_pos)

func _physics_process(delta: float) -> void:
	if navigation_agent_3d.is_navigation_finished():
		return

	var destination = navigation_agent_3d.get_next_path_position()
	var direction = global_position.direction_to(destination)

	velocity.x = direction.x * 5.0
	velocity.z = direction.z * 5.0

	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	move_and_slide()

func _on_navigation_agent_3d_navigation_finished() -> void:
	_generate_position()
