class_name DragAreaNode
extends Node2D

var throwed: bool = false
# areas and shapes
@onready var drag_area: Area2D = $DragArea
@onready var drag_area_shape: CollisionShape2D = $DragArea/DragAreaShape
@onready var click_area: Area2D = $ClickArea
@onready var click_area_shape: CollisionShape2D = $ClickArea/ClickAreaShape
@onready var on_click_area: bool = false


# circle props
@onready var circle: Line2D = $Circle
@onready var texture: Texture2D = circle.texture
@onready var segments: int = 32
@onready var trajectory: Line2D = $Trajectory

# The body owner of the area
@export var body: Throwable

# physics
@onready var impulse: Vector2
@onready var time_step = 0.02

func _ready() -> void:
	# Signals to check when mouse is inside the click area
	click_area.mouse_entered.connect(func (): on_click_area = true)
	click_area.mouse_exited.connect(func (): on_click_area = false)
	
	impulse = global_position

func _physics_process(delta: float) -> void:
	time_step = delta
	
func _draw() -> void:
	if body.state == Throwable.State.DRAG_STATE:
		_draw_circle()
		_draw_trajectory()

# Function to check the drag on the area
func input_action(event: InputEvent):
	if body.state == Throwable.State.IDLE_STATE:
		if event.is_action_pressed("click"):
			if event.is_pressed() and _mouse_over():
				body.state = Throwable.State.DRAG_STATE
		else:
			if _mouse_over():
				Input.set_custom_mouse_cursor(Game.HAND_OPEN_POINTER, Input.CURSOR_ARROW, Vector2(16, 16))
			else:
				Input.set_custom_mouse_cursor(Game.POINTER_CURSOR, Input.CURSOR_ARROW, Vector2(16, 16))
	elif body.state == Throwable.State.DRAG_STATE:
		Input.set_custom_mouse_cursor(Game.HAND_CLOSE_POINTER, Input.CURSOR_ARROW, Vector2(16, 16))
		# Direction and distance of the mouse position and body position
		var dir: Vector2 = (get_global_mouse_position() - body.global_position).normalized()
		var dist: float = get_global_mouse_position().distance_to(body.global_position)
		# if the mouse position is farest than area set the max radious
		if dist >= drag_area_shape.shape.radius:
			dist = drag_area_shape.shape.radius
		# calculate the impulse by the normalized vector and distance
		impulse = dir * -dist * body.throw_power
		queue_redraw()
		if event.is_action_released("click"):
			Input.set_custom_mouse_cursor(Game.POINTER_CURSOR, Input.CURSOR_ARROW, Vector2(16, 16))
			_clear()
			_throw.rpc(impulse)

# Function to check if the mouse is over the drag area
# return true if is over, false otherwise
func _mouse_over() -> bool:
	return on_click_area

# Function to execute the throw of the body
@rpc("any_peer", "call_local", "reliable")
func _throw(impulse: Vector2) -> void:
	throwed = true
	if body.freeze:
		body.freeze = false
	body.state = Throwable.State.MOVING_STATE
	body.apply_central_impulse(impulse)

# Function to draw circle arround the drag area
func _draw_circle() -> void:
	circle.clear_points()
	# its magic
	var angle_step = TAU / segments
	for i in range(segments):
		var angle = i * angle_step
		var x = drag_area_shape.shape.radius * cos(angle)
		var y = drag_area_shape.shape.radius * sin(angle)
		circle.add_point(Vector2(x, y))


# function to clear the draws (linear)
func _clear() -> void:
	circle.clear_points()
	trajectory.clear_points()


# function to draw the trajectory of a body
func _draw_trajectory():
	var init_pos = to_local(body.global_position)
	trajectory.clear_points()
	for i in range(40):
		var t = time_step * i
		var new_pos = init_pos + impulse/body.mass*t + Game.GRAVITY*t*t*0.5
		trajectory.add_point(new_pos)
