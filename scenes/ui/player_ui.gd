class_name PlayerUI
extends MarginContainer

@onready var role_text: Label = $VBoxContainer/TopBox/RoleText
@onready var bottom_box: HBoxContainer = $VBoxContainer/BottomBox
@onready var player: Statics.PlayerData
@onready var health_bars: Dictionary = {}

func _ready() -> void:
	player = Game.get_current_player()
	if player:
		role_text.text = "Role: {role}".format({"role": player.role})
	
	for i in Game.players.size():
		var id = Game.players[i].id
		var pg_bar = ProgressBar.new()
		pg_bar.max_value = Game.players_health[id]
		pg_bar.value = Game.players_health[id]
		pg_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		health_bars[id] = pg_bar
		bottom_box.add_child(pg_bar, true)
	# Connect to health signal to change the values on bars
	Game.health_changed.connect(_on_health_changed)
	
func _on_health_changed(key: int, value: int):
	health_bars[key].value -= value
