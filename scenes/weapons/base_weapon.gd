class_name BaseWeapon
extends Throwable

@onready var drag_area: DragAreaNode = $DragArea
@onready var activation_delay = 0
@onready var can_effect = false

func _ready() -> void:
	throw_power = 50
	drag_area.on_throw.connect(func() -> void :
		if activation_delay > 0:
			await get_tree().create_timer(activation_delay).timeout
		can_effect = true
	)


@rpc("any_peer", "call_local", "reliable")
func setup(id: int):
	set_multiplayer_authority(id)

# Input management
func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		drag_area.input_action(event)

# Phisics
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

@rpc("any_peer", "call_local", "reliable")
func init_pos(pos: Vector2):
	self.position = pos
