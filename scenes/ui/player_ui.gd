class_name PlayerUI
extends MarginContainer

const HEALTH_BAR_SCENE = preload("res://scenes/ui/health_bar.tscn")

@onready var role_text: Label = $VBoxContainer/TopBox/RoleText
@onready var turn_text: Label = $VBoxContainer/TopBox/TurnText
@onready var bottom_box: HBoxContainer = $VBoxContainer/BottomBox
@onready var player: Statics.PlayerData
@onready var health_bars: Dictionary = {}

func _ready() -> void:
	player = Game.get_current_player()
	if player:
		role_text.text = "Role: {role}".format({"role": player.role})
	
	for i in Game.players.size():
		var id = Game.players[i].id
		var health_bar = HEALTH_BAR_SCENE.instantiate()
		health_bar.max_value = Game.players_health[id]
		health_bar.value = Game.players_health[id]
		health_bars[id] = health_bar
		var cp_info = VBoxContainer.new()
		cp_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var label = Label.new()
		label.text = 'Role ' + str(Game.players[i].role)
		cp_info.add_child(label)
		cp_info.add_child(health_bar, true)
		bottom_box.add_child(cp_info)
	# Connect to health signal to change the values on bars
	Game.health_changed.connect(_on_health_changed)
	
func _on_health_changed(key: int, value: int):
	health_bars[key].value -= value
