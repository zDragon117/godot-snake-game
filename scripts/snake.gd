class_name Snake extends Node2D

signal ate
signal killed
signal recreate_fruit

@export var speed: int = 240

@onready var viewport_size = get_window().size
@onready var snake_segment: CharacterBody2D = $SnakeSegment
# [{"body": CharacterBody2D, "axis": Vector2}]
@onready var snake_segments: Array[Dictionary] = []

const SNAKE_SCENE = preload("res://scenes/snake.tscn")
const BODY_HORIZONTAL = preload("res://assets/textures/snake/body_horizontal.png")
const BODY_VERTICAL = preload("res://assets/textures/snake/body_vertical.png")
const BODY_TOPLEFT = preload("res://assets/textures/snake/body_topleft.png")
const BODY_TOPRIGHT = preload("res://assets/textures/snake/body_topright.png")
const BODY_BOTTOMLEFT = preload("res://assets/textures/snake/body_bottomleft.png")
const BODY_BOTTOMRIGHT = preload("res://assets/textures/snake/body_bottomright.png")
const HEAD_UP = preload("res://assets/textures/snake/head_up.png")
const HEAD_DOWN = preload("res://assets/textures/snake/head_down.png")
const HEAD_LEFT = preload("res://assets/textures/snake/head_left.png")
const HEAD_RIGHT = preload("res://assets/textures/snake/head_right.png")
const TAIL_UP = preload("res://assets/textures/snake/tail_up.png")
const TAIL_DOWN = preload("res://assets/textures/snake/tail_down.png")
const TAIL_LEFT = preload("res://assets/textures/snake/tail_left.png")
const TAIL_RIGHT = preload("res://assets/textures/snake/tail_right.png")

var fruit: Node
var direction = Vector2.ZERO
var temp_direction = Vector2.ZERO
var is_update_snake = false
var is_new_block = false
var is_dead = false
var head_graphic: Texture2D
var tail_graphic: Texture2D
var cell_size
var number_cells_x
var number_cells_y

func _ready() -> void:
	cell_size = get_tree().get_root().get_node("Game").CELL_SIZE
	number_cells_x = get_tree().get_root().get_node("Game").number_cells_x
	number_cells_y = get_tree().get_root().get_node("Game").number_cells_y
	
	snake_segments.append({"body": snake_segment, "axis": Vector2(4, number_cells_y / 2)})
	snake_segments.append({"body": snake_segment.duplicate(DUPLICATE_GROUPS), "axis": Vector2(3, number_cells_y / 2)})
	snake_segments[1]["body"].global_position = Vector2(snake_segments[1]["axis"].x * cell_size, snake_segments[1]["axis"].y * cell_size)
	add_child(snake_segments[1]["body"])
	snake_segments.append({"body": snake_segment.duplicate(DUPLICATE_GROUPS), "axis": Vector2(2, number_cells_y / 2)})
	snake_segments[2]["body"].global_position = Vector2(snake_segments[2]["axis"].x * cell_size, snake_segments[2]["axis"].y * cell_size)
	add_child(snake_segments[2]["body"])
	
func _physics_process(delta):
	# Handle input
	if Input.is_action_just_pressed("move_up") and direction != Vector2.DOWN:
		temp_direction = Vector2.UP
	elif Input.is_action_just_pressed("move_down") and direction != Vector2.UP:
		temp_direction = Vector2.DOWN
	elif Input.is_action_just_pressed("move_left") and direction != Vector2.RIGHT and direction != Vector2.ZERO:
		temp_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("move_right") and direction != Vector2.LEFT:
		temp_direction = Vector2.RIGHT
	
	if !is_update_snake and !is_dead:
		is_update_snake = true
		direction = temp_direction
		move_snake()
		check_fruit_collision()
		check_fail()
		await get_tree().create_timer(delta * 3600 / speed).timeout
		is_update_snake = false
	
	update_snake_graphics()

func update_snake_graphics():
	update_head_graphics()
	update_tail_graphics()

	for i in snake_segments.size():
		var pos = Vector2(int(snake_segments[i]["axis"].x * cell_size), int(snake_segments[i]["axis"].y * cell_size))
		snake_segments[i]["body"].global_position = pos
		
		if i == 0:
			snake_segments[i]["body"].get_node("Sprite2D").texture = head_graphic
		elif i == snake_segments.size() - 1:
			snake_segments[i]["body"].get_node("Sprite2D").texture = tail_graphic
		else:
			var previous_block = snake_segments[i + 1]["axis"] - snake_segments[i]["axis"]
			var next_block = snake_segments[i - 1]["axis"] - snake_segments[i]["axis"]
			if previous_block.x == next_block.x:
				snake_segments[i]["body"].get_node("Sprite2D").texture = BODY_VERTICAL
			elif previous_block.y == next_block.y:
				snake_segments[i]["body"].get_node("Sprite2D").texture = BODY_HORIZONTAL
			else:
				if (previous_block.x == -1 and next_block.y == -1) or (previous_block.y == -1 and next_block.x == -1):
					snake_segments[i]["body"].get_node("Sprite2D").texture = BODY_TOPLEFT
				elif (previous_block.x == -1 and next_block.y == 1) or (previous_block.y == 1 and next_block.x == -1):
					snake_segments[i]["body"].get_node("Sprite2D").texture = BODY_BOTTOMLEFT
				elif (previous_block.x == 1 and next_block.y == -1) or (previous_block.y == -1 and next_block.x == 1):
					snake_segments[i]["body"].get_node("Sprite2D").texture = BODY_TOPRIGHT
				elif (previous_block.x == 1 and next_block.y == 1) or (previous_block.y == 1 and next_block.x == 1):
					snake_segments[i]["body"].get_node("Sprite2D").texture = BODY_BOTTOMRIGHT

func update_head_graphics():
	var head_relation: Vector2 = snake_segments[0]["axis"] - snake_segments[1]["axis"]
	if head_relation == Vector2.LEFT or head_relation.x == number_cells_x - 1:
		head_graphic = HEAD_LEFT
	elif head_relation == Vector2.RIGHT or head_relation.x == 1 - number_cells_x:
		head_graphic = HEAD_RIGHT
	elif head_relation == Vector2.UP or head_relation.y == number_cells_y - 1:
		head_graphic = HEAD_UP
	elif head_relation == Vector2.DOWN or head_relation.y == 1 - number_cells_y:
		head_graphic = HEAD_DOWN

func update_tail_graphics():
	var tail_relation: Vector2 = snake_segments[-1]["axis"] - snake_segments[-2]["axis"]
	if tail_relation == Vector2.LEFT or tail_relation.x == number_cells_x - 1:
		tail_graphic = TAIL_LEFT
	elif tail_relation == Vector2.RIGHT or tail_relation.x == 1 - number_cells_x:
		tail_graphic = TAIL_RIGHT
	elif tail_relation == Vector2.UP or tail_relation.y == number_cells_y - 1:
		tail_graphic = TAIL_UP
	elif tail_relation == Vector2.DOWN or tail_relation.y == 1 - number_cells_y:
		tail_graphic = TAIL_DOWN

func move_snake():
	if direction != Vector2.ZERO:
		if is_new_block == true:
			var temp = {"body": snake_segment.duplicate(DUPLICATE_GROUPS), "axis": Vector2.ZERO}
			temp["axis"] = snake_segments[0]["axis"] + direction
			temp["axis"] = check_wall(temp["axis"])
			snake_segments.insert(0, temp)
			add_child(temp["body"])
			is_new_block = false
		else:
			var temp = snake_segments.pop_back()
			temp["axis"] = snake_segments[0]["axis"] + direction
			temp["axis"] = check_wall(temp["axis"])
			snake_segments.insert(0, temp)

func check_wall(snake_axis: Vector2) -> Vector2:
	if snake_axis.x > number_cells_x - 1:
		snake_axis.x = 0
	elif snake_axis.x < 0:
		snake_axis.x = number_cells_x - 1
	if snake_axis.y > number_cells_y - 1:
		snake_axis.y = 0
	elif snake_axis.y < 0:
		snake_axis.y = number_cells_y - 1
	return snake_axis

func check_fruit_collision():
	if fruit:
		if fruit.global_position == Vector2(snake_segments[0]["axis"].x * cell_size, snake_segments[0]["axis"].y * cell_size):
			ate.emit()
			recreate_fruit.emit()
			is_new_block = true
			speed += 10

		for segment in snake_segments:
			if fruit.global_position == Vector2(segment["axis"].x * cell_size, segment["axis"].y * cell_size):
				recreate_fruit.emit(true)

func check_fail():
	#if not 0 <= snake.body[0].x < cell_number or not 0 <= snake.body[0].y < cell_number:
		#game_over()

	for segment in snake_segments.slice(1):
		if segment["axis"].x == snake_segments[0]["axis"].x and segment["axis"].y == snake_segments[0]["axis"].y:
			is_dead = true
			killed.emit()
