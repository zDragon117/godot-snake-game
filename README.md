# Simple Snake game has graphics with Godot 4.4

### Load .import file instead of the file itself. This makes exported project load resources dynamically.
```python
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
```
