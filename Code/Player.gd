extends Area2D
export(float) var SPEED = 100.0

enum STATES { IDLE, FOLLOW }
var _state = null

var path = []
var target_point_world = Vector2()
var target_position = Vector2()

var velocity = Vector2()

onready var node_main = get_node("/root/Main")
onready var node_tile_map = get_parent().get_node('TileMap')

func _ready():
	_change_state(STATES.IDLE)

func _change_state(new_state):
	if new_state == STATES.FOLLOW:
		path = node_tile_map.find_path(position, target_position)
		if not path or len(path) == 1:
			_change_state(STATES.IDLE)
			print("Нет пути")
			return
		# The index 0 is the starting cell
		# we don't want the character to move back to it in this example
		target_point_world = path[1]
	_state = new_state


func _process(delta):
	if not _state == STATES.FOLLOW:
		return
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
		path.remove(0)
		
		var wtm = node_tile_map.world_to_map(target_point_world)
		var cell = node_tile_map.get_cellv(wtm)
		var cell_name = node_tile_map.tile_set.tile_get_name(cell)
		if node_main.general_get_card(cell_name):
			path.clear()
			
		if len(path) == 0:
			_change_state(STATES.IDLE)
			return
		target_point_world = path[0]


func move_to(world_position):
	var MASS = 1
	var ARRIVE_DISTANCE = 1

	var desired_velocity = (world_position - position).normalized() * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	position += velocity * get_process_delta_time()
	return position.distance_to(world_position) < ARRIVE_DISTANCE


func _unhandled_input(event):
	if (event.is_pressed() and event.button_index == BUTTON_LEFT):
		target_position = get_global_mouse_position()
		_change_state(STATES.FOLLOW)
