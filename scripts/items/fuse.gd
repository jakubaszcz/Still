extends Item

func _ready():
	item_name = Item.ItemType.FUSE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()
