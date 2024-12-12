class_name ItemFrame
extends Button

@onready var item_name: Label = $MarginContainer/Name
@onready var item_quantity: Label = $MarginContainer/Quantity

@export var text_name: String = "Name"
@export var text_quantity: String = "0"

func _ready() -> void:
	item_name.text = text_name
	item_quantity.text = text_quantity

func set_quantity(txt: String) -> void:
	item_quantity.text = txt
