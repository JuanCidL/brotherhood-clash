class_name DronWeapon
extends BaseWeapon
@export var stop_time = 1.0
var timer: float = 0.0
var timer2: float = 5.0
var timer3: float = 5.0
var syncro: float = false
#var timer4: float = 2.0
var is_stopped: bool = false
@export var move_speed: float = 200
@onready var hurt_area: Area2D = $HurtArea
@onready var damage = 10
var pos_fall: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	timer = stop_time
	throw_power = 10
	#sleeping = false
	gravity_again()
	damage = 50
	action_time = 15
	hurt_area.connect("body_entered", _on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if drag_area.throwed == true:
		if not is_stopped: 
			timer -= delta
			if timer <= 0.0:
				stop_rigid_body()	
		else: #Tiempo de vuelo dron out
			if timer2 >= 0.0:#El jugador puede mover el dron 
				timer2 -= delta
				no_gravity()
				handle_player_input(delta)	
			elif timer2 <= 0.0 and not syncro: #Si el tiempo de vuelo terminó ponemos la gravedad
				print("hola")
				pos_fall = self.global_position
				gravity_again()
				syncro = true
	#			action(delta)
			else: #timer2 terminó el jugaor ya no puede mover el dron,
				pass
				#timer3 -= delta
				#no_gravity()
#Devuelve la gravedad al valor normal
func gravity_again():
	syncronize_pos.rpc(position)
#Hace que el objeto flote
func no_gravity():
	if gravity_scale != 0.0:
		gravity_scale = 0.0
	
@rpc("any_peer","call_local","reliable")
func syncronize_pos(pos:Vector2):
	if gravity_scale != 1.0:
		gravity_scale = 1.0
	#self.position = pos
	
	
#Función para realizar una acción
#En este caso lo haremos explotar
#func action(delta:float):
#	timer4 -= delta
#	if timer4 == 0.0:
#		self.action_state = true
	
	

func stop_rigid_body():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = true
	is_stopped = true

func handle_player_input(delta: float):
	var move_direction = Vector2.ZERO
	#Detectamos las flechas
	if Input.is_action_pressed("ui_right"):
		move_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		move_direction.x -=1
	if Input.is_action_pressed("ui_down"):
		move_direction.y += 1
	if Input.is_action_pressed("ui_up"):
		move_direction.y -= 1
	
	#Normalizamos mov en diagonal
	if move_direction != Vector2.ZERO:
		move_direction = move_direction.normalized()
	
	#Aplica el movimiento al cuerpo rigido
	var pos = position + move_direction*move_speed*delta*2
	send_pos.rpc(pos)


@rpc("any_peer","call_local","unreliable_ordered")
func send_pos(pos:Vector2):
	self.position = pos
	
func _on_body_entered(body: Node2D):
	print("daño")
	if not can_effect:
		print("not daño")
		return
	body = body as BaseCharacter
	if body.id == Game.get_current_player().id && body.has_method("take_damage"):
		print("este si es daño")
		damage -= (pos_fall.y - body.global_position.y)/20
		print(damage)
		if damage >= 80:
			damage = 80
		body.take_damage.rpc(damage)
	await get_tree().create_timer(1).timeout
	queue_free()

	
