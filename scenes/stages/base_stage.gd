class_name BaseStage
extends Node2D

const PLAYER_UI = preload("res://scenes/ui/player_ui.tscn")
const PLACEHOLDER_SPRITE = preload("res://resources/pj_sinfondo.png")
const SPRITE_A = preload("res://resources/character_sprite/inge-dcc.png")
const SPRITE_B = preload("res://resources/character_sprite/inge-quim.png")
const SPRITE_C = preload("res://resources/character_sprite/inge-bio.png")
const SPRITE_D = preload("res://resources/character_sprite/inge-minas.png")

const MIN_MINION_QUANTITY = 3
const MAX_MINION_QUANTITY = 5

# Game states to handle the stage state
enum GameState{
	INIT,
	CHOOSING_PLACE,
	CHOOSING_WEAPON,
	PLAYING,
	END
}

# Game settings
@onready var teams_quantity: int = 2
@onready var minions_quantity: int = 1
@onready var game_state = GameState.INIT

# Players data 
@onready var players_data: Array[Statics.PlayerData] = []
@onready var player_id: int # local player id

# Characters data (Minions + Captain for each player)
@onready var characters: Dictionary # player_id: int -> characters: Array[BaseCharacter] // Map player id to player's characters

@onready var character_placeholder = MapUtils.role_to_character[Statics.Role.NONE]
@onready var sprite_placeholder: Sprite2D

# UI
@onready var canvas: CanvasLayer
@onready var player_ui: PlayerUI
@onready var timer_init: SceneTreeTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer_init = get_tree().create_timer(5)
	teams_quantity = Game.players.size()
	for i in Game.players.size():
		players_data.append(Game.players[i])
		var player = Game.players[i]
		var id = player.id
		var role = player.role
		_placeholder_setup(player.role)
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
		GameState.INIT:
			if timer_init.time_left > 0:
				var rounded_time = round(timer_init.time_left)
				player_ui.game_hint.text = 'Starts in ' + str(rounded_time) + " seconds"
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
				if characters[player_id].is_empty():
					game_state = GameState.END
					return
				var character: BaseCharacter = characters[player_id].front()
				if not character.is_enabled and character.player_state == BaseCharacter.PlayerState.IDLE:
					character.enable.rpc()
					player_ui.set_hint_text(str(players_data.front().role) + ' turn')
		GameState.END:
			pass

# call the only the random value of host 
@rpc('call_local', 'any_peer', 'reliable')
func _setup_current_player(cp: int):
	players_data.push_front(players_data.pop_at(cp))
	await timer_init.timeout
	player_ui.turn_text.text = 'Role ' + str(players_data.front().role) + ' turn'
	player_ui.set_hint_text(str(players_data.front().role) + ' turn')
	game_state = GameState.CHOOSING_PLACE
	
# Function to setup player UI
func _setup_ui():
	canvas = CanvasLayer.new()
	add_child(canvas, true)
	player_ui = PLAYER_UI.instantiate()
	canvas.add_child(player_ui, true)

# function to setup the placeholder spawn indicator
func _placeholder_setup(role: Statics.Role):
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
	var instance: BaseCharacter = character_placeholder.instantiate()
	
	# Obtener el rol del jugador asociado al `pid`
	var player_data: Statics.PlayerData = null
	for data in players_data:
		if data.id == pid:
			player_data = data
			break
	if player_data == null:
		Debug.log_error("No se encontró el jugador con ID %d" % pid)
		return
	
	# Asignar la textura en función del rol
	var sprite = instance.find_child("Sprite2D", true)
	var role = player_data.role
	match role:
		1:
			sprite.texture = SPRITE_A
		2:
			sprite.texture = SPRITE_B
		3:
			sprite.texture = SPRITE_C
		4:
			sprite.texture = SPRITE_D
		_:
			sprite.texture = PLACEHOLDER_SPRITE  # Textura por defecto
	# Configurar el personaje
	instance.setup(player_data)
	add_child(instance, true)
	
	# Configurar eventos para el jugador actual
	if Game.get_current_player().id == instance.id:
		instance.enabled.connect(func(value: bool) -> void:
			if value:
				show_inventory_button()
			else:
				hide_inventory_button()
		)
		player_ui.weapon_selected.connect(func(weapon: PackedScene) -> void:
			if not instance:
				return
			if not instance.is_enabled:
				return
			instance.disable.rpc()
			instance.on_weapon_instance(weapon)
			instance.change_state(BaseCharacter.PlayerState.WEAPON_THROWING)
		)

	# Añadir al mundo
	instance.global_position = mouse_pos
	instance.weapon_action.connect(_on_weapon_action)
	instance.die_signal.connect(_on_character_die)
	characters[pid].append(instance)

	# Cambiar turno
	_change_turn()
	
	# Verificar si todos los equipos tienen el mínimo de personajes
	var count: int = 0
	for arr in characters.values():
		if arr.size() < minions_quantity + 1:  # Minions + Capitán
			break
		count += 1
	if count == teams_quantity:
		_set_game_state(GameState.PLAYING)
		sprite_placeholder.hide()

# Handle the character turn with the current player id
@rpc('any_peer', 'call_local', 'reliable')
func _handle_character_turn(pid: int):
	# Disable the current character
	var id = players_data.front().id
	if characters[id].is_empty():
		game_state = GameState.END
		return
	var character: BaseCharacter = characters[pid].pop_front()
	character.disable()
	character.focus_disable.emit()
	characters[pid].push_back(character)
	
	_change_turn()
	
	# Next character turn
	var current_player: Statics.PlayerData = players_data.front()
	var new_id = current_player.id
	if characters[new_id].is_empty():
		game_state = GameState.END
		return
	var current_character: BaseCharacter = characters[new_id].front()
	current_character.enable()

# function to change player turn
@rpc('any_peer', 'call_local', 'reliable')
func _change_turn():
	var current_player: Statics.PlayerData = players_data.pop_front()
	players_data.push_back(current_player)
	current_player = players_data.front()
	player_ui.turn_text.text = 'Role ' + str(current_player.role) + ' turn'
	# Change hint text
	player_ui.set_hint_text(str(current_player.role) + ' turn')
	
# Character die handler
func _on_character_die(character: BaseCharacter):
	# pop from array and free
	characters[character.id].erase(character)
	character.queue_free()
	
# Handle after action weapon
func _on_weapon_action(character: BaseCharacter, weapon: BaseWeapon) -> void:
	hide_inventory_button()
	# Wait until time ends and then change turn
	player_ui.set_weapon_action_time.rpc(weapon.action_time)
	await get_tree().create_timer(weapon.action_time).timeout
	if is_instance_valid(character):
		_handle_character_turn.rpc(character.id)


func _set_game_state(st: GameState):
	game_state = st


# Inventory handling
func show_inventory_button() -> void:
	player_ui.show_inventory_button()
	
func hide_inventory_button() -> void:
	player_ui.hide_inventory_button()
	
func show_inventory() -> void:
	player_ui.show_inventory()
