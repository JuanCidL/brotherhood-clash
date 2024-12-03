class_name BaseStage
extends Node2D

const PLAYER_UI = preload("res://scenes/ui/player_ui.tscn")
const PLACEHOLDER_SPRITE = preload("res://resources/pj_sinfondo.png")

const MIN_MINION_QUANTITY = 3
const MAX_MINION_QUANTITY = 5

enum GameState{
	CHOOSING,
	PLAYING,
	END
}

# Game settings
@onready var teams_quantity: int = 2
@onready var minions_quantity: int = 1
@onready var game_state = GameState.CHOOSING

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
	var cp = randi_range(0, teams_quantity-1)
	#_setup_current_player.rpc(cp)
	_setup_ui()


func _process(delta: float) -> void:
	
	var mouse_pos = get_local_mouse_position()
		
	match game_state:
		GameState.CHOOSING:
			if player_id == players_data.front().id:
				_placeholder_draw.rpc(mouse_pos)
				if Input.is_action_just_pressed("click"):
					_handle_place.rpc(mouse_pos, player_id)
		GameState.PLAYING:
			if player_id == players_data.front().id:
				var character: BaseCharacter = characters[player_id].front()
				#if not character.drag_area.enabled:
				if not character.is_enabled:
					#character.drag_area.enabled = true
					character.enable.rpc()

# call the only the random value of host 
#@rpc('authority', 'call_local', 'reliable')
#func _setup_current_player(cp: int):
	#current_player = cp
	
# Function to setup player UI
func _setup_ui():
	# Ui setup
	#Debug.log("Role %s" % Game.players[current_player].role, 3)
	canvas = CanvasLayer.new()
	add_child(canvas, true)
	player_ui = PLAYER_UI.instantiate()
	canvas.add_child(player_ui, true)
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
# it alse manage the turns increasing the current character index on the specific player
@rpc("any_peer", "call_local", "reliable")
func _handle_place(mouse_pos: Vector2, pid: int):
	# Instance a new character and setup it in the scene
	var instance: BaseCharacter = default_player.instantiate()
	var data: Statics.PlayerData = players_data.front()
	instance.setup(data, characters[data.id])
	add_child(instance, true)
	
	# Signals detection to handle the turns on move or throw
	instance.drag_area.on_throw.connect(func() -> void:
		instance.disable.rpc()
		_handle_turn(pid)
	)
	instance.on_weapon_spawn.connect(func(weapon: BaseWeapon) -> void:
		instance.disable()
		weapon.drag_area.on_throw.connect(func() -> void:
			weapon.disable.rpc()
			_handle_turn.rpc(pid)
		)
	)
	# Add to world
	instance.global_position = mouse_pos
	characters[pid].append(instance)
	#instance.array = characters[pid] 
	
	_handle_turn(pid)
	
	var count: int = 0
	for arr in characters.values():
		if arr.size()<minions_quantity+1: # minions quantities + captain
			break 
		count+=1
	if count==teams_quantity:
		_set_playing_state()

@rpc('any_peer', 'call_local', 'reliable')
func _handle_turn(pid: int):
	####
	##LISTO
	#if game_state == GameState.PLAYING:
		#var character: BaseCharacter = characters[pid][current_character[pid]]
		#character.disable.rpc()
	#
	##YA NO VA
	#var new_character_index = current_character[pid] + 1
	#if new_character_index >= characters[pid].size():
		#new_character_index = 0
	#current_character[pid] = new_character_index
	#
	##LISTO
	#var new_player_index = current_player + 1
	#if new_player_index >= players_data.size():
		#new_player_index = 0
	#current_player = new_player_index
	#
	#
	#if game_state == GameState.PLAYING:
		#var new_player_id = players_data[current_player].id
		#var character: BaseCharacter = characters[new_player_id][current_character[new_player_id]]
		#character.enable.rpc()
	####
	
	# Disable the current character
	if game_state == GameState.PLAYING:
		var character: BaseCharacter = characters[pid].pop_front()
		character.disable()
		characters[pid].push_back(character)
	
	# Change player turn
	var current_player: Statics.PlayerData = players_data.pop_front()
	players_data.push_back(current_player)
	current_player = players_data.front()
	
	# Next character turn
	if game_state == GameState.PLAYING:
		var new_id = current_player.id
		if characters[new_id].is_empty():
			game_state = GameState.END
		var current_character: BaseCharacter = characters[new_id].front()
		current_character.enable()
	
		
	player_ui.turn_text.text = 'Role ' + str(current_player.role) + ' turn'
	

func _set_playing_state():
	game_state = GameState.PLAYING
	sprite_placeholder.hide()
