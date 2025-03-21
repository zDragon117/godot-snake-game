class_name Snake extends Node2D

signal ate
signal killed
signal recreate_fruit

@export var speed: int = 30

@onready var snake_segment: CharacterBody2D = $SnakeSegment
# [{"body": CharacterBody2D, "position": Vector2}]
@onready var snake_segments: Array[Dictionary] = []

const CELL_SIZE: int = 40
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
var head_graphic: Texture2D
var tail_graphic: Texture2D

func _ready() -> void:
	snake_segments.append({"body": snake_segment, "position": Vector2(5,10)})
	snake_segments.append({"body": snake_segment.duplicate(DUPLICATE_GROUPS), "position": Vector2(4,10)})
	snake_segments.append({"body": snake_segment.duplicate(DUPLICATE_GROUPS), "position": Vector2(3,10)})
	
func _physics_process(delta):
	# Handle input
	if Input.is_action_just_pressed("move_up") and direction != Vector2.DOWN:
		temp_direction = Vector2.UP
	elif Input.is_action_just_pressed("move_down") and direction != Vector2.UP:
		temp_direction = Vector2.DOWN
	elif Input.is_action_just_pressed("move_left") and direction != Vector2.RIGHT:
		temp_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("move_right") and direction != Vector2.LEFT:
		temp_direction = Vector2.RIGHT
	
	if !is_update_snake:
		is_update_snake = true
		move_snake()
		update_snake_graphics()
		check_fruit_collision()
		check_fail()
		await get_tree().create_timer(delta * speed).timeout
		is_update_snake = false

func eat_the_fruit():
	ate.emit()
	
func update_snake_graphics():
	update_head_graphics()
	update_tail_graphics()

	for i in snake_segments.size():
		var position = Vector2(int(snake_segments[i]["position"].x * CELL_SIZE), int(snake_segments[i]["position"].y * CELL_SIZE))

		if i == 0:
			snake_segments[i]["body"].get_node("Sprite2D").texture = head_graphic
		elif i == snake_segments.size() - 1:
			var temp = snake_segment.duplicate(DUPLICATE_GROUPS)
			snake_segments[i]["body"].get_node("Sprite2D").texture = tail_graphic
		else:
			var previous_block = snake_segments[i + 1]["position"] - snake_segments[i]["position"]
			var next_block = snake_segments[i - 1]["position"] - snake_segments[i]["position"]
			if previous_block.x == next_block.x:
				snake_segments[i]["body"].get_node("Sprite2D").texture = BODY_VERTICAL
			elif previous_block.y == next_block.y:
				snake_segments[i]["body"].get_node("Sprite2D").texture = BODY_HORIZONTAL
			else:
				if previous_block.x == -1 and next_block.y == -1 or previous_block.y == -1 and next_block.x == -1:
					snake_segments[i]["body"].get_node("Sprite2D").texture = BODY_TOPLEFT
				elif previous_block.x == -1 and next_block.y == 1 or previous_block.y == 1 and next_block.x == -1:
					snake_segments[i]["body"].get_node("Sprite2D").texture = BODY_BOTTOMLEFT
				elif previous_block.x == 1 and next_block.y == -1 or previous_block.y == -1 and next_block.x == 1:
					snake_segments[i]["body"].get_node("Sprite2D").texture = BODY_TOPRIGHT
				elif previous_block.x == 1 and next_block.y == 1 or previous_block.y == 1 and next_block.x == 1:
					snake_segments[i]["body"].get_node("Sprite2D").texture = BODY_BOTTOMRIGHT

func update_head_graphics():
	var head_relation = snake_segments[0]["position"] - snake_segments[1]["position"]
	if head_relation == Vector2.LEFT: head_graphic = HEAD_LEFT
	elif head_relation == Vector2.RIGHT: head_graphic = HEAD_RIGHT
	elif head_relation == Vector2.UP: head_graphic = HEAD_UP
	elif head_relation == Vector2.DOWN: head_graphic = HEAD_DOWN

func update_tail_graphics():
	var tail_relation = snake_segments[-1]["position"] - snake_segments[-2]["position"]
	if tail_relation == Vector2.LEFT: tail_graphic = TAIL_LEFT
	elif tail_relation == Vector2.RIGHT: tail_graphic = TAIL_RIGHT
	elif tail_relation == Vector2.UP: tail_graphic = TAIL_UP
	elif tail_relation == Vector2.DOWN: tail_graphic = TAIL_DOWN

func move_snake():
	if is_new_block == true:
		var temp = snake_segment.duplicate(DUPLICATE_GROUPS)
		temp["position"] = snake_segments[0]["position"] + temp_direction
		snake_segments.insert(0, temp)
		is_new_block = false
	else:
		var temp = snake_segments.pop_back()
		temp["position"] = snake_segments[0]["position"] + temp_direction
		snake_segments.insert(0, temp)

func check_fruit_collision():
	if fruit.global_position == snake_segments[0]["position"]:
		recreate_fruit.emit(true)
		is_new_block = true

	for segment in snake_segments:
		if segment["position"] == fruit.global_position:
			recreate_fruit.emit(true)

func check_fail():
	#if not 0 <= snake.body[0].x < cell_number or not 0 <= snake.body[0].y < cell_number:
		#game_over()

	for segment in snake_segments.slice(1):
		if segment["position"] == snake_segments[0]["position"]:
			killed.emit()
