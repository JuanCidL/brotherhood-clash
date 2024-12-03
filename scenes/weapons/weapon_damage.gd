extends BaseWeapon

@onready var damage = 10
@onready var hurt_area: Area2D = $HurtArea

func _ready() -> void:
	hurt_area.connect("body_entered", _on_body_entered)
	super._ready()
	throw_power = 10
	
func _on_body_entered(body: Node2D):
	if not can_effect:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	await get_tree().create_timer(1).timeout
	queue_free()
