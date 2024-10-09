class_name DronWeapon
extends BaseWeapon
@export var stop_time = 2.0
var timer: float = 0.0
var is_stopped: bool = false
@export var move_speed: float = 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = stop_time
	throw_power = 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_stopped: 
		timer -= delta
		if timer <= 0.0:
			stop_rigid_body()	
	else:
		handle_player_input(delta)	

func stop_rigid_body():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	#sleeping = true
	is_stopped = true
func handle_player_input(delta: float):
	var move_direction = Vector2.ZERO
	
	#Detectamos las flechas
	if Input.is_action_pressed("ui_right"):
		move_direction.x += 1
	if Input.is_action_pressed("ui.left"):
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

	
