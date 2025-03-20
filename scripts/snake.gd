class_name Snake extends Node2D

signal ate
signal killed

@export var speed: int = 30

@onready var snake_segment: CharacterBody2D = $SnakeSegment
@onready var body_scenes: Array[PackedScene] = []
@onready var body_array: Array[Vector2] = [Vector2(5,10),Vector2(4,10),Vector2(3,10)]

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

var direction = Vector2.ZERO
var temp_direction = Vector2.ZERO
var body_segments = []
var is_update_snake = false
var head_graphic: Texture2D
var tail_graphic: Texture2D

func _ready() -> void:
	pass
	
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
		draw_snake()
		## Move the head
		#direction = temp_direction
		#var move_vector = direction * CELL_SIZE
		#global_position += move_vector
		#
		## Move the body segments
		#if body_segments.size() > 0:
			#for i in range(body_segments.size() - 1, 0, -1):
				#body_segments[i].global_position = body_segments[i - 1].global_position
			#body_segments[0].global_position = global_position - move_vector
#
		## Handle collisions
		#for segment in body_segments:
			#if global_position == segment.global_position:
				#killed.emit()

		await get_tree().create_timer(delta * speed).timeout
		is_update_snake = false

func eat_the_fruit():
	ate.emit()
	
func draw_snake():
	update_head_graphics()
	update_tail_graphics()

	for i in body_array.size():
		var position = Vector2(int(body_array[i].x * CELL_SIZE), int(body_array[i].y * CELL_SIZE))

		if i == 0:
			add_body_segment(snake_segment, position, head_graphic)
		elif i == body_array.size() - 1:
			var temp = snake_segment.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS)
			add_body_segment(temp, position, tail_graphic)
		else:
			var previous_block = body_array[i + 1] - body_array[i]
			var next_block = body_array[i - 1] - body_array[i]
			if previous_block.x == next_block.x:
				var temp = snake_segment.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS)
				add_body_segment(temp, position, BODY_VERTICAL) # draw body_vertical
			elif previous_block.y == next_block.y:
				var temp = snake_segment.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS)
				add_body_segment(temp, position, BODY_HORIZONTAL) # draw body_horizontal
			else:
				if previous_block.x == -1 and next_block.y == -1 or previous_block.y == -1 and next_block.x == -1:
					var temp = snake_segment.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS)
					add_body_segment(temp, position, BODY_TOPLEFT) # draw body_topleft
				elif previous_block.x == -1 and next_block.y == 1 or previous_block.y == 1 and next_block.x == -1:
					var temp = snake_segment.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS)
					add_body_segment(temp, position, BODY_BOTTOMLEFT) # draw body_bottomleft
				elif previous_block.x == 1 and next_block.y == -1 or previous_block.y == -1 and next_block.x == 1:
					var temp = snake_segment.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS)
					add_body_segment(temp, position, BODY_TOPRIGHT) # draw body_topright
				elif previous_block.x == 1 and next_block.y == 1 or previous_block.y == 1 and next_block.x == 1:
					var temp = snake_segment.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS)
					add_body_segment(temp, position, BODY_BOTTOMRIGHT) # draw body_bottomright

func update_head_graphics():
	var head_relation = body_array[0] - body_array[1]
	if head_relation == Vector2.LEFT: head_graphic = HEAD_LEFT
	elif head_relation == Vector2.RIGHT: head_graphic = HEAD_RIGHT
	elif head_relation == Vector2.UP: head_graphic = HEAD_UP
	elif head_relation == Vector2.DOWN: head_graphic = HEAD_DOWN

func update_tail_graphics():
	var tail_relation = body_array[-1] - body_array[-2]
	if tail_relation == Vector2.LEFT: tail_graphic = TAIL_LEFT
	elif tail_relation == Vector2.RIGHT: tail_graphic = TAIL_RIGHT
	elif tail_relation == Vector2.UP: tail_graphic = TAIL_UP
	elif tail_relation == Vector2.DOWN: tail_graphic = TAIL_DOWN

func add_body_segment(segment: CharacterBody2D, position: Vector2, texture: Texture2D):
	segment.global_position = position
	segment.get_node("Sprite2D").texture = texture
	add_child(segment)
