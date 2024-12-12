class_name PlayerUI
extends MarginContainer

const HEALTH_BAR_SCENE = preload("res://scenes/ui/health_bar.tscn")

@onready var role_text: Label = $VBoxContainer/TopBox/RoleText
@onready var turn_text: Label = $VBoxContainer/TopBox/TurnText
@onready var action_text: Label = $VBoxContainer/TopBox/ActionText
@onready var bottom_box: HBoxContainer = $VBoxContainer/BottomBox
@onready var player: Statics.PlayerData
@onready var enemy: Statics.PlayerData
@onready var health_bars: Dictionary = {}

#Referencias a los nodos de Victory y Lose Screen
@onready var game_hint: Label = $GameHint
@onready var victory_screen = $VictoryScreen
@onready var lose_screen = $LoseScreen2

# Inventory
@onready var character_inventory: CharacterInventory = $CharacterInventory
@onready var inventory_button: Button = $InventoryButton
@onready var character: BaseCharacter # Character to get the quantities

# Timers
@onready var action_timer: SceneTreeTimer

# Signal for select
signal weapon_selected(weapon: PackedScene)

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
	# Connect the button to show/hide the inventory
	inventory_button.button_down.connect(func() -> void: character_inventory.visible = !character_inventory.visible)
	# Connect the child item select signal
	character_inventory.item_selected.connect(func(item: PackedScene) -> void:
		weapon_selected.emit(item)
	)
	
func _process(delta: float) -> void:
	if action_timer and action_timer.time_left > 0:
		var rounded_time = round(action_timer.time_left)
		action_text.text = "Time left: " + str(rounded_time)
	else:
		if action_text.text != '':
			action_text.text = ''
	
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

func set_hint_text(text: String, lifetime: float = 1) -> void:
	game_hint.modulate = Color(1,1,1,0)
	game_hint.text = text
	var tween = get_tree().create_tween()
	tween.tween_property(game_hint, "modulate", Color(1,1,1,1), 0.5)
	await get_tree().create_timer(lifetime).timeout
	tween = get_tree().create_tween()
	tween.tween_property(game_hint, "modulate", Color(1,1,1,0), 1)

@rpc("any_peer","call_local","reliable")
func show_victory():
	victory_screen.visible = true
@rpc("any_peer","call_local","reliable")
func show_lose():
	lose_screen.visible = true

@rpc("any_peer", "call_local", "reliable")
func set_weapon_action_time(time: float):
	action_timer = get_tree().create_timer(time)
	
func show_inventory_button() -> void:
	inventory_button.show()
	inventory_button.disabled = false

func hide_inventory_button() -> void:
	inventory_button.hide()
	inventory_button.disabled = true
	
func show_inventory() -> void:
	character_inventory.show()
	
