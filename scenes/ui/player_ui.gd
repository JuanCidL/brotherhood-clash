class_name PlayerUI
extends MarginContainer

const HEALTH_BAR_SCENE = preload("res://scenes/ui/health_bar.tscn")

@onready var role_text: Label = $VBoxContainer/TopBox/RoleText
@onready var turn_text: Label = $VBoxContainer/TopBox/TurnText
@onready var bottom_box: HBoxContainer = $VBoxContainer/BottomBox
@onready var player: Statics.PlayerData
@onready var enemy: Statics.PlayerData
@onready var health_bars: Dictionary = {}

#Referencias a los nodos de Victory y Lose Screen
@onready var victory_screen = $VictoryScreen
@onready var lose_screen = $LoseScreen2


func _ready() -> void:
	victory_screen.visible = false
	lose_screen.visible = false
	
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
	if(health_bars[key].value <= 0):
		print("funcionaa"+str(key))
		if Game.get_current_player().id == key:
			print("A este pendejo se le cayó la barra\n")
			lose_screen.show()
			#show_lose()
		else: 
			print("A este ELSE se le cayó la barra\n")
			victory_screen.show()
			#show_victory()
		
@rpc("any_peer","call_local","reliable")
func show_victory():
	victory_screen.visible = true
@rpc("any_peer","call_local","reliable")
func show_lose():
	lose_screen.visible = true
