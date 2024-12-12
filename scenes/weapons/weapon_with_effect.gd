class_name WeaponWithEffect
extends BaseWeapon

#Variables
@export var stop_time = 5.0
var timer: float = 0.0
var time_out: bool = false
var effect_power: float
var effect_activated: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = stop_time
	throw_power = 10
	effect_power = 100
	effect_activated = false
	drag_area.on_throw.connect(func() -> void :
		if activation_delay > 0:
			await get_tree().create_timer(activation_delay).timeout
		can_effect = true
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	print("physics weaponwitheffect")
	start_timer(delta)
	pass
func start_timer(delta) -> void: 
	if drag_area.throwed == true:
		if not time_out: 
			timer -= delta
			if timer <= 0.0:
				stop_rigid_body()	
		else: #Espera terminada
			drag_area.throwed = false
			effect_activated = true
			
func weapon_effect(power: float) -> void:
	print("Se activó el que no era")
	pass

#Función para cuando un objeto queda sin timer y debe generar su efecto
#en el aire o quieto en tierra
func stop_rigid_body():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = true
	time_out = true
