extends Node2D

@export var number_cells_x = 24
@export var number_cells_y = 14

@onready var viewport_size = get_window().size
@onready var fruit = $Fruit
@onready var snake = $SnakeSegments
@onready var crunch_sound = $SFX/Crunch
@onready var background_music = $SFX/BackgroundMusic
@onready var start_game = $SFX/StartGame
@onready var hud = $UILayer/HUD
@onready var gos = $UILayer/GameOverScene

const CELL_SIZE: int = 40
var fruits: Array[Texture2D] = []
var current_fruits: Array[Texture2D] = []
var score = 0:
	set(value):
		score = value
		hud.total_score = score
var high_score

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(number_cells_x * CELL_SIZE, number_cells_y * CELL_SIZE))
	viewport_size = get_window().size
	var save_file = FileAccess.open("user://save.data", FileAccess.READ)
	if save_file != null:
		high_score = save_file.get_32()
	else:
		high_score = 0
		save_game()
	score = 0
	hud.total_fruits_container.global_position = Vector2(viewport_size.x - 180, viewport_size.y - 60)
	hud.fruit_detail_container.global_position = Vector2(viewport_size.x - 630, viewport_size.y - 110)
	
	queue_redraw()
	preload_all_fruits()
	prepare_fruit()
	snake.viewport_size = viewport_size
	snake.fruit = fruit
	snake.ate.connect(_on_ate_fruit)
	snake.killed.connect(_on_snake_killed)
	snake.recreate_fruit.connect(prepare_fruit)
	start_game.play(0.5)
	background_music.play()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _draw():
	# draw background
	var columns: int = viewport_size.x / CELL_SIZE
	var rows: int = viewport_size.y / CELL_SIZE
	
	for y in range(rows):
		for x in range(columns):
			var color = Color8(167,209,61) if (x + y) % 2 == 0 else Color8(175,215,70)
			draw_rect(Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)

func preload_all_fruits():
	# Load all textures from the fruits folder
	var dir_path = "res://assets/textures/fruits/"
	var dir = DirAccess.open(dir_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with('.png.import'):
				fruits.append(load(dir_path + file_name.replace('.import', '')))
			#elif file_name.ends_with(".png"):  # Adjust for other formats if needed
				#fruits.append(ResourceLoader.load(dir_path + file_name, "Texture2D"))
			file_name = dir.get_next()
		dir.list_dir_end()

func prepare_fruit(is_only_set_position: bool = false):
	if !is_only_set_position:
		#current_fruits.erase(fruit.get_node("Sprite2D").texture)
		#if current_fruits.size() == 0:
			#current_fruits = fruits.duplicate()
		fruit.get_node("Sprite2D").texture = fruits.pick_random()
	
	# set fruit position to random cell
	fruit.global_position = Vector2(randi_range(0, viewport_size.x / CELL_SIZE - 1) * CELL_SIZE, randi_range(0, viewport_size.y / CELL_SIZE - 1) * CELL_SIZE)

func save_game():
	var save_file = FileAccess.open("user://save.data", FileAccess.WRITE)
	save_file.store_32(high_score)

func _on_ate_fruit():
	score += 1
	if score > high_score:
		high_score = score
	var i = fruits.find(fruit.get_node("Sprite2D").texture)
	hud.list_score[i].text = str(int(hud.list_score[i].text) + 1)
	crunch_sound.play()
	
func _on_snake_killed():
	gos.set_score(score)
	gos.set_high_score(high_score)
	save_game()
	await get_tree().create_timer(0.5).timeout
	gos.visible = true
