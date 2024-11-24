class_name WeaponWithEffect
extends BaseWeapon

#Variables
@export var stop_time = 5.0
var timer: float = 0.0
var time_out: bool = false
var effect_power: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = stop_time
	throw_power = 10
	effect_power = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if drag_area.throwed == true:
		if not time_out: 
			timer -= delta
			if timer <= 0.0:
				stop_rigid_body()	
		else: #Espera terminada
			weapon_effect(effect_power)

func weapon_effect(power: float) -> void:
	pass

#Función para cuando un objeto queda sin timer y debe generar su efecto
#en el aire o quieto en tierra
func stop_rigid_body():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = true
	time_out = true
