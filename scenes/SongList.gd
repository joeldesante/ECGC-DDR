extends VBoxContainer

func preview_song(song_uri):
	var loaded_song = load(song_uri)
	$AudioStreamPlayer.set_stream(loaded_song)
	$AudioStreamPlayer.play(10.0)
	
func _on_option_hovered(song_uri):
	preview_song(song_uri)
	
func _on_option_selected(song):
	Global.selected_song = song
	get_tree().change_scene_to_file("res://scenes/stage_a.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var song_option_button = load("res://components/song_option.tscn")
	
	# 1. Load the songs choices
	var song_choices = load("res://song_choices.json")
	
	# 2. Generate the buttons
	for song in song_choices.data:
		var option = song_option_button.instantiate()
		option.set_text(song.title)
		option.mouse_entered.connect(func(): _on_option_hovered(song.resource_uri))
		option.mouse_exited.connect(func(): $AudioStreamPlayer.stop())
		option.pressed.connect(func(): _on_option_selected(song))
		add_child(option)
	
	# 3. Display the buttons
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_mouse_entered():
	pass # Replace with function body.
