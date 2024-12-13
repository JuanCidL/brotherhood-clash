class_name DinamiteWeapon
extends BaseWeapon

#@onready var explosion_area: Area2D = $ExplosionArea

@onready var impulse = 200
@export var stop_time = 5.0
var timer: float = 0.0
var time_out: bool = false
var explosion_inst
#@onready var sprite = $SpriteDinamite
@export var explosion_scene: PackedScene = preload("res://explosion.tscn")
#@onready var animation = $ExplosionArea/ExplosionAnimation
#@onready var spriteAnimation:Sprite2D = $ExplosionArea/SpriteExplosion
#@onready var animation_tree: AnimationTree = $ExplosionArea/AnimationTree

var effect_power
var effect_activated
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	action_time = 10
	timer = stop_time
	effect_power = 100
	throw_power = 10
	effect_activated = false
	drag_area.on_throw.connect(func() -> void :
		if activation_delay > 0:
			await get_tree().create_timer(activation_delay).timeout
		can_effect = true
	)
	
# physics_process propio
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	start_timer(delta)
	if effect_activated:
		weapon_effect(effect_power)
		effect_activated = false

func start_timer(delta) -> void: 
	if drag_area.throwed == true:
		if not time_out: 
			timer -= delta
			if timer <= 0.0:
				stop_rigid_body()    
		else: #Espera terminada
			drag_area.throwed = false
			effect_activated = true
func stop_rigid_body():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = true
	time_out = true

#Funcion para hacer especificamente lo que se quiere de DinamiteWeapon
func weapon_effect(power: float) -> void:
	explosion()
	await get_tree().create_timer(1.5).timeout
	self.visible = false
	#spriteAnimation.visible = false
	#for node in explosion_area.get_overlapping_bodies():
	#    if not can_effect:
	#        return
	#    if node.has_method("take_damage"):
	#        node.take_damage(power - global_position.distance_to(node.global_position))
	#        node.apply_central_impulse(global_position.direction_to(node.global_position))
	#    await get_tree().create_timer(5).timeout
	#    queue_free()
# Recuperar animation player en el codigo
# Hacer un timer await get_tree().create_timer(5).timeout
func explosion() -> void: 
	if not explosion_scene:
		return
	var explosion_inst = explosion_scene.instantiate()
	explosion_inst.global_position = global_position
	get_parent().add_child(explosion_inst)
	await get_tree().create_timer(2.2).timeout
	explosion_inst.visible = false
