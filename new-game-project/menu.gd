extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	# Load the next level or scene (replace "NextLevel.tscn" with the actual scene path)
	var next_scene = preload("res://Scenes/Main.tscn")

func _on_quit_pressed() -> void:
	# Quit the game
	get_tree().quit()
