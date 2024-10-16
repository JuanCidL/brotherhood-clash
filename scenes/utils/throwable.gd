class_name Throwable
extends RigidBody2D
	
# Action state of the current body
enum State {
	IDLE_STATE,
	MOVING_STATE,
	DRAG_STATE,
}
# initial and current state
var state: State = State.IDLE_STATE	
# The throw power
var throw_power: float = 5
# Enabled state
var is_enabled = false
signal enabled(value: bool)

# process to reset the state to idle when |velocity| = 0
func _physics_process(_delta: float) -> void:
	if linear_velocity <= Vector2(0.001, 0.001) and state == State.MOVING_STATE:
		state = State.IDLE_STATE

# Function to set enabled with signal
@rpc("any_peer", "call_local", "reliable")
func enable():
	is_enabled = true
	enabled.emit(true)

@rpc("any_peer", "call_local", "reliable")
# Function to set disbled with signal
func disable():
	is_enabled = false
	enabled.emit(false)
