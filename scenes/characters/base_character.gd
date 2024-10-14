class_name BaseCharacter
extends Throwable

# Character properties
var health: int = Game.MINION_MAX_HEALTH
var weapons: Array = Array([], TYPE_OBJECT, "", null)

# Debug
var weapon_scene = preload("res://scenes/weapons/weapon_damage.tscn")
var weapon_instance: BaseWeapon = null
@onready var weapon_spawn: Marker2D = $WeaponSpawn
@onready var node: Node = $Node

# Visual properties
@onready var drag_area: DragAreaNode = $DragArea
@onready var health_bar: ProgressBar = $HealthBar

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
			_on_weapon_instance()

# Phisics
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

@rpc
func _send_position(pos: Vector2):
	self.position = pos 

@rpc("authority", "reliable")
func _on_weapon_instance():
	if is_instance_valid(weapon_instance):
		weapon_instance.queue_free()
	weapon_instance = weapon_scene.instantiate()
	weapon_instance.global_position = weapon_spawn.global_position
	node.add_child(weapon_instance, true)
	weapon_instance.setup.rpc(get_multiplayer_authority())	
	weapon_instance.init_pos.rpc(weapon_spawn.global_position)

@rpc("any_peer", "call_local", "reliable")
func take_damage(value: int):
	if health <= 0:
		return
	health -= value
	health_bar.value -= value
	Game.take_damage(Game.get_current_player().id, value)
	set_collision_mask_value(3, false)
	await get_tree().create_timer(2).timeout
	set_collision_mask_value(3, true)
	
