class_name BaseCharacter
extends Throwable

# Character properties
var health: int = 100
var weapons: Array = Array([], TYPE_OBJECT, "", null)

# Debug
var weapon_scene = preload("res://scenes/weapons/base_weapon.tscn")
var dron_scene = preload("res://scenes/weapons/dron_weapon.tscn")
var weapon_instance: BaseWeapon = null
@onready var weapon_spawn: Marker2D = $WeaponSpawn
@onready var weapon_spawner: MultiplayerSpawner = $WeaponSpawner
@onready var node: Node = $Node

# Visual properties
@onready var drag_area: DragAreaNode = $DragArea


# multiplayer setup
func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)

func _ready() -> void:
	throw_power = 10

# Input management
func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		drag_area.input_action(event)
		
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

@rpc
func _send_position(pos: Vector2):
	self.position = pos 

func _on_weapon_instance(arma: PackedScene):
	if weapon_instance:
		weapon_instance.queue_free()
	weapon_instance = arma.instantiate()
	weapon_instance.global_position = weapon_spawn.global_position
	node.add_child(weapon_instance, true)
	weapon_instance.setup.rpc(get_multiplayer_authority())	
	weapon_instance.init_pos.rpc(weapon_spawn.global_position)
