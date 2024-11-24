class_name BaseStage
extends Node2D

const PLAYER_UI = preload("res://scenes/ui/player_ui.tscn")
const PLACEHOLDER_SPRITE = preload("res://resources/pj_sinfondo.png")

const MIN_MINION_QUANTITY = 3
const MAX_MINION_QUANTITY = 5

# Game states to handle the stage state
enum GameState{
	CHOOSING_PLACE,
	CHOOSING_WEAPON,
	PLAYING,
	END
}

# Game settings
@onready var teams_quantity: int = 2
@onready var minions_quantity: int = 1
@onready var game_state = GameState.CHOOSING_PLACE

# Players data 
@onready var players_data: Array[Statics.PlayerData] = []
@onready var player_id: int # local player id

# Characters data (Minions + Captain for each player)
@onready var characters: Dictionary # player_id: int -> characters: Array[BaseCharacter] // Map player id to player's characters

@onready var default_player = RoleMap.map[Statics.Role.NONE]
@onready var sprite_placeholder: Sprite2D

# UI
@onready var canvas: CanvasLayer
@onready var player_ui: PlayerUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_placeholder_setup()
	teams_quantity = Game.players.size()
	for i in Game.players.size():
		players_data.append(Game.players[i])
		var id = Game.players[i].id
		characters[id] = []
		Game.players_health[id] = Game.MINION_MAX_HEALTH * (minions_quantity+1)
	player_id = Game.get_current_player().id
	if Game.get_current_player().id == 1:
		var cp = randi_range(0, teams_quantity-1)
		_setup_current_player.rpc(cp)
	_setup_ui()


func _process(delta: float) -> void:
	
	var mouse_pos = get_local_mouse_position()
		
	match game_state:
		GameState.CHOOSING_PLACE:
			if player_id == players_data.front().id:
				_placeholder_draw.rpc(mouse_pos)
				if Input.is_action_just_pressed("click"):
					_handle_place.rpc(mouse_pos, player_id)
		GameState.CHOOSING_WEAPON:
			if player_id == players_data.front().id:
				pass
		GameState.PLAYING:
			if player_id == players_data.front().id:
				var character: BaseCharacter = characters[player_id].front()
				if not character.is_enabled:
					character.enable.rpc()

# call the only the random value of host 
@rpc('call_local', 'any_peer', 'reliable')
func _setup_current_player(cp: int):
	players_data.push_front(players_data.pop_at(cp))
	
# Function to setup player UI
func _setup_ui():
	canvas = CanvasLayer.new()
	add_child(canvas, true)
	player_ui = PLAYER_UI.instantiate()
	canvas.add_child(player_ui, true)
	await get_tree().create_timer(2).timeout
	player_ui.turn_text.text = 'Role ' + str(players_data.front().role) + ' turn'

# function to setup the placeholder spawn indicator
func _placeholder_setup():
	sprite_placeholder = Sprite2D.new()
	add_child(sprite_placeholder, true)
	sprite_placeholder.texture = PLACEHOLDER_SPRITE
	sprite_placeholder.scale = Vector2(0.25, 0.25)
	sprite_placeholder.modulate.a = 0.4

# function to draw the placeholder in all game instances 
@rpc("any_peer", "call_local", "unreliable_ordered")
func _placeholder_draw(mouse_pos: Vector2):
	sprite_placeholder.global_position = mouse_pos

# function to spawn the character instances in all game instances and save it in Map structs
@rpc("any_peer", "call_local", "reliable")
func _handle_place(mouse_pos: Vector2, pid: int):
	# Instance a new character and setup it in the scene
	var instance: BaseCharacter = default_player.instantiate()
	var data: Statics.PlayerData = players_data.front()
	instance.setup(data, self)
	add_child(instance, true)

	# Add to world
	instance.global_position = mouse_pos
	characters[pid].append(instance)

	# change turn
	_change_turn()
	
	var count: int = 0
	for arr in characters.values():
		if arr.size()<minions_quantity+1: # minions quantities + captain
			break 
		count+=1
	if count==teams_quantity:
		_set_game_state(GameState.PLAYING)
		sprite_placeholder.hide()

# Handle the character turn with the current player id
@rpc('any_peer', 'call_local', 'reliable')
func handle_character_turn(pid: int):
	# Disable the current character
	var character: BaseCharacter = characters[pid].pop_front()
	character.disable()
	characters[pid].push_back(character)
	
	_change_turn()
	
	# Next character turn
	var current_player: Statics.PlayerData = players_data.front()
	var new_id = current_player.id
	if characters[new_id].is_empty():
		game_state = GameState.END
	var current_character: BaseCharacter = characters[new_id].front()
	current_character.enable()

# function to change player turn
@rpc('any_peer', 'call_local', 'reliable')
func _change_turn():
	var current_player: Statics.PlayerData = players_data.pop_front()
	players_data.push_back(current_player)
	current_player = players_data.front()
	player_ui.turn_text.text = 'Role ' + str(current_player.role) + ' turn'

func _set_game_state(st: GameState):
	game_state = st

func show_inventory_button() -> void:
	player_ui.show_inventory_button()
	
func show_inventory() -> void:
	player_ui.show_inventory()
