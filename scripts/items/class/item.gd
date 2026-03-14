extends CharacterBody3D
class_name Item

enum ItemType { ITEM, KEY }

@export var item_name: ItemType = ItemType.ITEM

func _hold(new_parent: Node3D, local_pos: Vector3):
	print("Holding item" + str(item_name))
	GSignals.make_noise.emit(NoiseManager.new(global_position, 0.3))
	get_parent().remove_child(self)
	new_parent.add_child(self)
	position = local_pos
	rotation = Vector3.ZERO
	
func _drop(global_pos: Vector3):
	print("Dropping item" + str(item_name))
	var world: Node = get_tree().current_scene
	get_parent().remove_child(self)
	world.add_child(self)
	global_position = global_pos
