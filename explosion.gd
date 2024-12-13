extends Area2D

var damage
@onready var explosion_damage_area: CollisionShape2D = $ExplosionDamageArea
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damage = 90
	for player in get_overlapping_bodies():
	#for node in explosion_damage_area.get_overlapping_bodies():
		print("on body entered")
		_on_body_entered(player)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_body_entered(body: Node2D):
	print("cuerpo dentro")
	if body.has_method("take_damage"):
		print("Take Damage")
		body.take_damage(damage)
	await get_tree().create_timer(1).timeout
	queue_free()
