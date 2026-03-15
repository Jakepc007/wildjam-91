extends CharacterBody2D
class_name Guard

@export var line_of_sight_detector : LineOfSightDetector
@export var navigation_agent_2d : NavigationAgent2D
@export var debug_player : Node2D
@export var DEBUG_PRINT_TRANSITIONS : bool = false
@export var patrol_points : Array[Node2D]
var _current_patrol_point_idx : int

signal player_spotted()
signal player_caught()

enum States {
	CHASE,
	PATROL,
	INVESTIGATE_SPOT,
}

var _state : States :
	set(new_state):
		if new_state == _state:
			return
		var old_state = _state
		if DEBUG_PRINT_TRANSITIONS:
			prints("guard state change",States.find_key(new_state))
		exit_actions(old_state,new_state)
		_state = new_state
		enter_actions(old_state,new_state)

var _last_global_position_detected : Vector2
var _investigate_target_location : Vector2

@export var chase_speed : float = 300
@export var patrol_speed : float = 100
@export var turn_speed : float = 2
@export var walk_speed : float = 150
@export var acceleration : float = 5
@export var investigation_time : float = 3.0
var _time_spent_investigating : float


func _ready() -> void:
	_current_patrol_point_idx = 0
	_state = States.PATROL

func exit_actions(old_state : States, new_state : States):
	match old_state:
		States.CHASE:
			_investigate_target_location = _last_global_position_detected

func enter_actions(old_state : States, new_state : States):
	match new_state:
		States.PATROL:
			assert(patrol_points.size() > 0, "Guard:" + name + " cannot patrol without patrol points")
			set_navigation_target(patrol_points[0].global_position)
		States.INVESTIGATE_SPOT:
			_time_spent_investigating = 0
			set_navigation_target(_investigate_target_location)


func _physics_process(delta: float) -> void:
	match _state:
		States.CHASE:
			if not line_of_sight_detector.player_in_line_of_sight(debug_player.global_position):
				_state = States.INVESTIGATE_SPOT
				move_and_slide()
				return
			# get vector to target
			_last_global_position_detected = debug_player.global_position
			var target_forward_direction = debug_player.global_position - global_position
			target_forward_direction = target_forward_direction.normalized()
			velocity = velocity.lerp(target_forward_direction * chase_speed, delta * acceleration)
		States.INVESTIGATE_SPOT:
			if navigation_agent_2d.is_navigation_finished():
				velocity = Vector2.ZERO
				_time_spent_investigating += delta
				if _time_spent_investigating > investigation_time:
					_state = States.PATROL
					move_and_slide()
					return
			else:
				move_with_navigation_agent(patrol_speed)

		States.PATROL:
			if line_of_sight_detector.player_detected(debug_player.global_position):
				_state = States.CHASE
				move_and_slide()
				return
			patrol_update()
	move_and_slide()

func pick_random_spot(radius : float):
	return min(randf(),0.3)*radius*Vector2(randf()*2 - 1,randf()*2 - 1)

func patrol_update():
	if navigation_agent_2d.is_navigation_finished():
		_current_patrol_point_idx = (_current_patrol_point_idx + 1) % patrol_points.size()
		set_navigation_target(patrol_points[_current_patrol_point_idx].global_position)

	move_with_navigation_agent(patrol_speed)

func move_with_navigation_agent(speed : float):
	if navigation_agent_2d.is_navigation_finished():
		return
	# Get the next point in the path
	var current_pos = global_position
	var next_path_pos = navigation_agent_2d.get_next_path_position()
	
	# Calculate velocity
	var new_velocity = (next_path_pos - current_pos).normalized() * speed
	velocity = new_velocity
	move_and_slide()

func set_navigation_target(target_point: Vector2):
	navigation_agent_2d.target_position = target_point

func player_detected() -> bool:
	if debug_player:
		return line_of_sight_detector.player_detected(debug_player.global_position)
	else:
		return false
