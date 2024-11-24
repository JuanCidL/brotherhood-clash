class_name BaseCharacter
extends Throwable

# Player state
enum PlayerState {
	IDLE,
	PLAYER_THROWING,
	CHOOSING_WEAPON,
	WEAPON_THROWING,
}

# Game state
@onready var player_state: PlayerState = PlayerState.IDLE
signal state_change(state)


# Character properties
@onready var health: int = Game.MINION_MAX_HEALTH
@onready var weapons: Array = Array([], TYPE_OBJECT, "", null)
@onready var id: int
@onready var stage: BaseStage

# Debug
@onready var weapon_scene = preload("res://scenes/weapons/weapon_damage.tscn")
@onready var dron_scene = preload("res://scenes/weapons/dron_weapon.tscn")
@onready var weapon_instance: BaseWeapon = null

@onready var weapon_spawn: Marker2D = $WeaponSpawn
@onready var node: Node = $Node
signal spawn_weapon(weapon: BaseWeapon)

# Visual properties
@onready var drag_area: DragAreaNode = $DragArea
@onready var health_bar: ProgressBar = $HealthBar
@onready var turn_mark: Line2D = $Pivot/TurnMark

# sync
@onready var replication_timer: Timer = $ReplicationTimer

# multiplayer setup
func setup(player_data: Statics.PlayerData, stg: BaseStage) -> void:
	name = str(player_data.id)
	id = player_data.id
	set_multiplayer_authority(player_data.id)
	disable()
	stage = stg

func _ready() -> void:
	if is_multiplayer_authority():
		# Handle launch
		drag_area.on_throw.connect(func() -> void:
			player_state = PlayerState.CHOOSING_WEAPON
			stage.show_inventory_button()
		)
		# Handle activation state
		enabled.connect(func(value: bool):
			turn_mark.visible = value
			if value:
				player_state = PlayerState.PLAYER_THROWING
		)
		# Handle when a attack
		spawn_weapon.connect(func(weapon: BaseWeapon) -> void:
			weapon.drag_area.on_throw.connect(func() -> void:
				disable.rpc()
				if stage:
					stage.handle_character_turn.rpc(id)
		))
	throw_power = 10
	# Randomize a start time to begin replicating the pos and velocity of characters
	var delay = randf()*0.5
	await get_tree().create_timer(delay).timeout
	if is_multiplayer_authority():
		replication_timer.timeout.connect(func() -> void:
			_replicate.rpc(self.position, self.linear_velocity)
		)
	
# Input management
func _input(event: InputEvent) -> void:
	if not is_enabled:
		return
	
	if is_multiplayer_authority():
		match player_state:
			PlayerState.PLAYER_THROWING:
				drag_area.input_action(event)
			
			PlayerState.CHOOSING_WEAPON:
				if event.is_action_released("number_1"):
					_on_weapon_instance(weapon_scene)
				if event.is_action_released("number_2"):
					_on_weapon_instance(dron_scene)
				#if event.is_action_released("number_2"):
					#_on_weapon_instance(weapon_scene)
				if event.is_action_released("number_3"):
					_on_weapon_instance(weapon_scene)
				if event.is_action_released("number_4"):
					_on_weapon_instance(weapon_scene)
				if event.is_action_released("number_5"):
					_on_weapon_instance(weapon_scene)
		

# Phisics
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	

@rpc("authority", "call_remote")
func _replicate(pos: Vector2, vel: Vector2):
	self.position = pos 
	self.linear_velocity = vel

@rpc("authority", "reliable")
func _on_weapon_instance(arma: PackedScene):
	if is_instance_valid(weapon_instance):
		weapon_instance.queue_free()
	weapon_instance = arma.instantiate()
	weapon_instance.global_position = weapon_spawn.global_position
	node.add_child(weapon_instance, true)
	weapon_instance.setup.rpc(get_multiplayer_authority())	
	weapon_instance.init_pos.rpc(weapon_spawn.global_position)
	spawn_weapon.emit(weapon_instance)

@rpc("any_peer", "call_local", "reliable")
func take_damage(value: int):
	if health <= 0:
		if stage:
			stage.characters[id].erase(self)
			queue_free()
		return
	health -= value
	health_bar.value -= value
	Game.take_damage(id, value)
	set_collision_mask_value(3, false)
	await get_tree().create_timer(2).timeout
	set_collision_mask_value(3, true)

func change_state(state: PlayerState) -> void:
	player_state = state
	state_change.emit(state)
