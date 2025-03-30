extends Control

@onready var total_fruits_container = $TotalFruitsContainer
@onready var fruit_detail_container = $FruitDetailContainer
@onready var total_score = $TotalFruitsContainer/HBoxContainer/MarginContainer/TotalScore:
	set(value):
		total_score.text = str(value)
@onready var list_score: Array[Label] = []

var tween: Tween = null  # Store the tween to control it


func _ready():
	fruit_detail_container.modulate.a = 0  # Make sure it's fully transparent
	fruit_detail_container.visible = false  # Hide it initially
	load_fruit_detail_container()


func _on_total_fruits_container_mouse_entered() -> void:
	if tween:
		tween.kill()  # Stop any existing tween
	fruit_detail_container.visible = true
	tween = get_tree().create_tween()
	tween.tween_property(fruit_detail_container, "modulate:a", 1.0, 0.3)  # Fade in


func _on_total_fruits_container_mouse_exited() -> void:
	if tween:
		tween.kill()  # Stop any exi
	tween = get_tree().create_tween()
	tween.tween_property(fruit_detail_container, "modulate:a", 0.0, 0.3)  # Fade out
	await tween.finished  # Wait for fade-out animation
	fruit_detail_container.visible = false


func load_fruit_detail_container():
	# Load all textures from the fruits folder
	var dir_path = "res://assets/textures/fruits/"
	var dir = DirAccess.open(dir_path)
	var container = fruit_detail_container.get_node("HBoxContainer")
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with('.png.import'):
				var fruit_texture = fruit_detail_container.get_node("HBoxContainer/Fruit").duplicate()
				var margin_container = fruit_detail_container.get_node("HBoxContainer/MarginContainer").duplicate()
				fruit_texture.texture = load(dir_path + file_name.replace('.import', ''))
				fruit_texture.visible = true
				margin_container.visible = true
				container.add_child(fruit_texture)
				container.add_child(margin_container)
				list_score.append(margin_container.get_node("FruitScore"))
			#elif file_name.ends_with(".png"):  # Adjust for other formats if needed
				#fruits.append(ResourceLoader.load(dir_path + file_name, "Texture2D"))
			file_name = dir.get_next()
		dir.list_dir_end()
