class_name DronWeapon
extends BaseWeapon
@export var stop_time = 1.0
var timer: float = 0.0
var timer2: float = 5.0
var timer3: float = 5.0
#var timer4: float = 2.0
var is_stopped: bool = false
@export var move_speed: float = 200
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = stop_time
	throw_power = 10
	sleeping = false
	gravity_again()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if drag_area.throwed == true:
		if not is_stopped: 
			timer -= delta
			if timer <= 0.0:
				stop_rigid_body()	
		else:
			if timer2 >= 0.0:
				timer2 -= delta
				handle_player_input(delta)	
			if timer3 <= 0.0:
				gravity_again()
	#			action(delta)
			else:
				timer3 -= delta
				no_gravity()
#Devuelve la gravedad al valor normal
func gravity_again():
	gravity_scale = 1
#Hace que el objeto flote
func no_gravity():
	gravity_scale = 0.0

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
	position += move_direction*move_speed*delta

	
