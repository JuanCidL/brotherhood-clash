class_name BaseStage
extends Node2D

const PLAYER_UI = preload("res://scenes/ui/player_ui.tscn")
const PLACEHOLDER_SPRITE = preload("res://resources/pj_sinfondo.png")

const MIN_MINION_QUANTITY = 3
const MAX_MINION_QUANTITY = 5

enum GameState{
	CHOOSING,
	PLAYING
}

# Game settings
@onready var teams_quantity: int = 2
@onready var minions_quantity: int = 4
@onready var game_state = GameState.CHOOSING

# Players data 
@onready var players_data: Array[Statics.PlayerData] = []
@onready var current_player: int # index of player in  player data
@onready var player_id: int

# Characters data (Minions + Captain for each player)
@onready var characters: Dictionary # player_id: int -> characters: Array[BaseCharacter] // Map player id to player's characters
@onready var current_character: Dictionary # player_id -> character_index: int // Map player id to character index in characters array

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
		current_character[id] = 0
		Game.players_health[id] = Game.MINION_MAX_HEALTH * minions_quantity
	current_player = randi_range(0, teams_quantity-1)
	player_id = Game.get_current_player().id
	_setup_ui()


func _process(delta: float) -> void:
	
	var mouse_pos = get_local_mouse_position()
	
	#Game.take_damage.rpc(player_id, 1)
	
	match game_state:
		GameState.CHOOSING:
			if player_id == players_data[current_player].id:
				_placeholder_draw.rpc(mouse_pos)
				if Input.is_action_just_pressed("click"):
					_handle_place.rpc(mouse_pos, player_id)
			
# Function to setup player UI
func _setup_ui():
	# Ui setup
	Debug.log("Role %s" % Game.players[current_player].role, 3)
	canvas = CanvasLayer.new()
	add_child(canvas, true)
	player_ui = PLAYER_UI.instantiate()
	canvas.add_child(player_ui, true)

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
func _handle_place(mouse_pos: Vector2, player_id: int):
	var instance: BaseCharacter = default_player.instantiate()
	add_child(instance, true)
	instance.global_position = mouse_pos
	characters[player_id].append(instance)
	
	var new_character_index = current_character[player_id] + 1
	if new_character_index >= characters[player_id].size():
		new_character_index = 0
	current_character[player_id] = new_character_index
	
	var new_player_index = current_player + 1
	if new_player_index >= players_data.size():
		new_player_index = 0
	current_player = new_player_index
	#Debug.log("Role %s" % Game.players[current_player].role, 3)
	# Chsing condition (if quantity is complete, change state to playing)
	var count: int = 0
	for arr in characters.values():
		if arr.size()<minions_quantity+1: # minions quantities + captain
			break 
		count+=1
	if count==teams_quantity:
		_set_playing_state()


func _set_playing_state():
	game_state = GameState.PLAYING
	sprite_placeholder.hide()
