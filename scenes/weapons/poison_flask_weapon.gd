class_name PoisonFlaskWeapon
extends WeaponWithEffect

@onready var impulse = 500
var poison_scene = preload("res://scenes/weapons/poison_scene.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	effect_power = 50

#Funcion para hacer especificamente lo que se quiere de DinamiteWeapon
func weapon_effect(power: float) -> void:
	if not poison_scene:
		print("No cargó bien")
		return
	#var poison_instance = poison_scene.instance()
	#poison_instance.global_position = global_position
	#get_tree().get_root().add_child(poison_instance)
