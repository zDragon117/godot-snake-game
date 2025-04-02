extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # Keep the pause menu working when game is paused


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			visible = false
			get_tree().set_pause(false)
		else:
			visible = true
			get_tree().set_pause(true)
