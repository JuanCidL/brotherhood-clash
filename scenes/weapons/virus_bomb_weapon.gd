class_name VirusBombWeapon
extends WeaponWithEffect

@onready var impulse = 500
var smoke_scene = preload("res://scenes/weapons/smoke_scene.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	effect_power = 0
	drag_area.on_throw.connect(func() -> void :
		if activation_delay > 0:
			await get_tree().create_timer(activation_delay).timeout
		can_effect = true
	)

#Funcion para hacer especificamente lo que se quiere de DinamiteWeapon
func weapon_effect(power: float) -> void:
	if not smoke_scene:
		print("No cargó bien")
		return
	#var smoke_instance = smoke_scene.instance()
	#smoke_instance.global_position = global_position
	#get_tree().get_root().add_child(smoke_instance)
	
	
