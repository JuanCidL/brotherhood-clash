extends BaseWeapon

@onready var damage = 10
@onready var hurt_area: Area2D = $HurtArea

func _ready() -> void:
	super._ready()
	hurt_area.connect("body_entered", _on_body_entered)
	throw_power = 10
	damage = 50
	
func _on_body_entered(body: Node2D):
	if not can_effect:
		print("weapon-damage-not can effect")
		return
	body = body as BaseCharacter
	if body.id == Game.get_current_player().id && body.has_method("take_damage"):
		body.take_damage.rpc(damage)
	await get_tree().create_timer(1).timeout
	queue_free()
