extends CharacterBody3D
class_name Item

enum ItemType { ITEM, FUSE }

@export var item_name: ItemType = ItemType.ITEM
@export var noise_on_drop: float = 0.5
@export var noise_on_pickup: float = 0.2

func _hold():
	print("Holding item" + str(item_name))
	
func _drop():
	print("Dropping item" + str(item_name))
