class_name CharacterInventory
extends Control

@onready var item_container: GridContainer = $SelectContainer/Inventory/InventoryGrid/ItemContainer
signal item_selected(item: PackedScene)

func _ready() -> void:
	for i in range(item_container.get_child_count()):
		var child: ItemFrame = item_container.get_child(i)
		# Handle press mapping item name to the weapon scene
		child.pressed.connect(func() -> void:
			_on_select_item(MapUtils.weapon_map[child.item_name.text])
		)

func set_quantities(arr: Array[int]):
	for i in range(item_container.get_child_count()):
		var child: ItemFrame = item_container.get_child(i)
		child.set_quantity(str(arr[i]))

# Callback for item selection
func _on_select_item(item: PackedScene):
	hide()
	item_selected.emit(item)
	
