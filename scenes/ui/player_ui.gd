extends Control

@onready var role_text: Label = $VBoxContainer/Control/VBoxContainer/RoleText
@onready var player: Statics.PlayerData

func _ready() -> void:
	player = Game.get_current_player()
	role_text.text = "Role: {role}".format({"role": player.role})
