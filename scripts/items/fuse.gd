extends Item

func _ready():
	print("Fuse has been created")
	item_name = Item.ItemType.KEY

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()
