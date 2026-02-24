extends Node2D

@export var _dimensions : Vector2i = Vector2i(7,5)
@export var _start : Vector2i = Vector2i(-1,-1) #Random start position by default 

@export var _critical_path_length : int = 13 #Shorts path from start to end

@export var _branches : int = 3 #branch so not a linear path
@export var _branch_length : Vector2i = Vector2i(1,4) #3 branches with rooms of length 1 to 4 each
var _branch_candidates : Array[Vector2i] #list of rooms that could have branches added to them 

var dungeon : Array 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_dungeon()
	_place_enterance()
	_generate_path(_start, _critical_path_length, "C")
	_generate_branches()
	_print_dungeon()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _initialize_dungeon() -> void:
	for x in _dimensions.x:
		dungeon.append([])
		for y in _dimensions.y:
			dungeon[x].append(0)
			
func _place_enterance() -> void:
	if _start.x < 0 or _start.x >= _dimensions.x:
		_start.x = randi_range(0, _dimensions.x - 1) #if start invalid make a valid start position 
	if _start.y < 0 or _start.y >= _dimensions.y:
		_start.y = randi_range(0, _dimensions.y - 1)
	dungeon[_start.x][_start.y] = "S"
	
func _generate_path(from : Vector2i, length : int, marker : String) -> bool:
	if length == 0:
		return true
	var current : Vector2i = from
	var direction : Vector2i
	match randi_range(0,3):
		0:
			direction = Vector2i.UP
		1: 
			direction = Vector2i.RIGHT
		2:
			direction = Vector2i.DOWN
		3:
			direction = Vector2i.LEFT
	for i in 4: #4 possible directions 
		if(current.x + direction.x >= 0 and current.x + direction.x < _dimensions.x
			and current.y + direction.y >= 0 and current.y + direction.y < _dimensions.y 
			and not dungeon[current.x + direction.x][current.y + direction.y]): #Must be empty
				current += direction
				dungeon[current.x][current.y] = marker
				if length > 1: #last room cannot be a branch candidate
					_branch_candidates.append(current)
				if _generate_path(current, length - 1, marker):
					return true
				else:
					_branch_candidates.erase(current)
					dungeon[current.x][current.y] = 0
					current -= direction 
		direction = Vector2(direction.y, -direction.x) #rotate directions 
	return false 
			
func _generate_branches() -> void:
	var branches_created : int = 0
	var candidate : Vector2i #room we are branching off from 
	while branches_created < _branches and _branch_candidates.size(): #if too tight dungeon then less branches is ok
		candidate = _branch_candidates[randi_range(_branch_length.x, _branch_length.y)] #select a random branch candidate
		if _generate_path(candidate, randi_range(_branch_length.x, _branch_length.y), str(branches_created + 1)):
			branches_created += 1
		else:
			_branch_candidates.erase(candidate)
			
			
func _print_dungeon() -> void:
	var dungeon_as_string : String = ""
	for y in range(_dimensions.y-1, -1, -1): #top row and count down to 0
		for x in _dimensions.x:
			if dungeon[x][y]:
				dungeon_as_string += "[" + str(dungeon[x][y]) + "]"
			else:
				dungeon_as_string += "   "
		dungeon_as_string += '\n'
	print(dungeon_as_string)
