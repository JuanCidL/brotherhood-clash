class_name DinamiteWeapon
extends WeaponWithEffect

@onready var explosion_area: Area2D = $ExplosionArea
@onready var impulse = 500
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	effect_power = 100

#Funcion para hacer especificamente lo que se quiere de DinamiteWeapon
func weapon_effect(power: float) -> void:
	for node in explosion_area.get_overlapping_bodies():
		if not can_effect:
			return
		if node.has_method("take_damage"):
			node.take_damage(power - global_position.distance_to(node.global_position))
			node.apply_central_impulse(global_position.direction_to(node.global_position))
		await get_tree().create_timer(5).timeout
		queue_free()
# Recuperar animation player en el codigo
# Hacer un timer await get_tree().create_timer(5).timeout
	nodo_AnimationPlayer.play("explosion")
