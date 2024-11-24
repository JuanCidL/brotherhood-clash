class_name CharacterInventory
extends Control

@onready var item_container: GridContainer = $SelectContainer/Inventory/InventoryGrid/ItemContainer

func set_quantities(arr: Array[int]):
	for i in item_container.get_child_count():
		var child: ItemFrame = item_container.get_child(i)
		child.set_quantity(str(arr[i]))
