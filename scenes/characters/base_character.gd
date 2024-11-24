class_name BaseCharacter
extends Throwable


# Character properties
var health: int = Game.MINION_MAX_HEALTH
var weapons: Array = Array([], TYPE_OBJECT, "", null)
var id: int
var array: Array

# Debug
var weapon_scene = preload("res://scenes/weapons/weapon_damage.tscn")
var dron_scene = preload("res://scenes/weapons/dron_weapon.tscn")
var dinamite_scene = preload("res://scenes/weapons/dinamite_weapon.tscn")
var weapon_instance: BaseWeapon = null

@onready var weapon_spawn: Marker2D = $WeaponSpawn
@onready var node: Node = $Node
signal on_weapon_spawn(weapon: BaseWeapon)

# Visual properties
@onready var drag_area: DragAreaNode = $DragArea
@onready var health_bar: ProgressBar = $HealthBar
@onready var turn_mark: Line2D = $Pivot/TurnMark

# sync
@onready var replication_timer: Timer = $ReplicationTimer

# multiplayer setup
func setup(player_data: Statics.PlayerData, arr) -> void:
	name = str(player_data.id)
	id = player_data.id
	set_multiplayer_authority(player_data.id)
	disable()
	enabled.connect(func(value: bool): turn_mark.visible = value)
	array = arr

func _ready() -> void:
	throw_power = 10
	var delay = randf()*0.5
	await get_tree().create_timer(delay).timeout
	replication_timer.timeout.connect(func() -> void: _replicate.rpc(self.position, self.linear_velocity))
	
# Input management
func _input(event: InputEvent) -> void:
	if not is_enabled:
		return
	if is_multiplayer_authority():
		drag_area.input_action(event)
		
		if event.is_action_released("number_1"):
			_on_weapon_instance(weapon_scene)
		if event.is_action_released("number_2"):
			_on_weapon_instance(dron_scene)
		if event.is_action_released("number_3"):
			_on_weapon_instance(dinamite_scene)
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
	on_weapon_spawn.emit(weapon_instance)

@rpc("any_peer", "call_local", "reliable")
func take_damage(value: int):
	if health <= 0:
		if array:
			array.erase(self)
			queue_free()
		return
	health -= value
	health_bar.value -= value
	Game.take_damage(id, value)
	set_collision_mask_value(3, false)
	await get_tree().create_timer(2).timeout
	set_collision_mask_value(3, true)
	
func push(direction: Vector2, impulse: float) -> void:
	velocity += direction * impulse
