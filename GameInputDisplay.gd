extends Node
var Timing = preload("res://components/timing/timing.tscn")
var Track = preload("res://components/track/track.tscn")

enum Direction {
	LEFT = 0,
	RIGHT = 3,
	UP = 1,
	DOWN = 2 
}

enum DanceInputs {
	LEFT = 68,
	RIGHT = 65,
	DOWN = 83,
	UP = 87
}

signal track_started(time_msec)
signal inputs_updated(inputs)
signal draw_arrow(track, offset_time)
signal update_status(status)

var presong_delay_msec = 4000
var track_start_time = -1
var track_time = 0
var pressed_keys = []
var ui_tracks = []
var timings = {
	left = [
		Timing.instantiate().init(1000, Direction.LEFT),
		Timing.instantiate().init(2000, Direction.LEFT),
		Timing.instantiate().init(3000, Direction.LEFT),
		Timing.instantiate().init(4000, Direction.LEFT),
		Timing.instantiate().init(5000, Direction.LEFT),
		Timing.instantiate().init(6000, Direction.LEFT),
		Timing.instantiate().init(7000, Direction.LEFT),
		Timing.instantiate().init(8000, Direction.LEFT),
		Timing.instantiate().init(9000, Direction.LEFT),
	],
	right = [
		Timing.instantiate().init(1000, Direction.RIGHT),
		Timing.instantiate().init(2000, Direction.RIGHT),
		Timing.instantiate().init(3000, Direction.RIGHT),
		Timing.instantiate().init(4000, Direction.RIGHT),
		Timing.instantiate().init(5000, Direction.RIGHT),
		Timing.instantiate().init(6000, Direction.RIGHT),
		Timing.instantiate().init(7000, Direction.RIGHT),
	],
	up = [
		Timing.instantiate().init(1000, Direction.UP),
	],
	down = [
		Timing.instantiate().init(1000, Direction.DOWN),
	]
}

func change_pose(pose_name):	# TODO: Change to POSE URI and store the poses and the combos in a JSON file
	var loaded_texture = load("res://poses/" + pose_name + ".png")	#TODO: Preload these assets!!!
	$CharacterSprite.set_texture(loaded_texture)
	
func load_song(song_uri):
	var loaded_song = load(song_uri)
	$AudioStreamPlayer.set_stream(loaded_song)

func get_time_since_track_start():
	return Time.get_ticks_msec() - track_start_time
	
func get_nearest_track_timing(timings, track_elapsed_time):
	var nearest_timing = null
	for timing in timings:
		var magnitude = abs(track_elapsed_time - timing.timestamp_msec)
		if nearest_timing == null:
			nearest_timing = [ timing, magnitude ]
			continue
		if magnitude < nearest_timing[1]:
			nearest_timing = [ timing, magnitude ]
	
	if nearest_timing == null:
		return null
		
	return nearest_timing[0]

func execute_track_timing(timings):
	var track_elapsed_time = get_time_since_track_start()
	
	# TODO: Support all the timing tracks
	var nearest_timing = get_nearest_track_timing(timings, track_elapsed_time)
	if nearest_timing == null:
		print("Nearest timing is null")
		return
	
	var time_until_timing_msec = nearest_timing.timestamp_msec - track_elapsed_time
	
	if nearest_timing.is_hit:
		return
	
	nearest_timing.hit(time_until_timing_msec)
	
	if(time_until_timing_msec < -100):
		print("Late!")
		update_status.emit("Late!")
	elif time_until_timing_msec > 100:
		print("Early!")
		update_status.emit("Early!")
	else:
		print("Perfect!")
		update_status.emit("Perfect!")

func _on_inputs_changed(inputs):
	if inputs.find(DanceInputs.LEFT) > -1:
		execute_track_timing(timings.left)
		change_pose("d_slide")
		
	if inputs.find(DanceInputs.RIGHT) > -1:
		execute_track_timing(timings.right)
		change_pose("a_slide")
		
	if inputs.find(DanceInputs.UP) > -1:
		execute_track_timing(timings.up)
		change_pose("up_pose")
		
	if inputs.find(DanceInputs.DOWN) > -1:
		execute_track_timing(timings.down)
		change_pose("drop_it")
	
func _ready():
	
	# print(Global.selected_song)
	
	if(Global.selected_song == null):
		print("Error selecting song!")
		return
	
	# Load the timings data for the song
	# var song_timings = load("res://timings/phonky_killah.timings.txt")
	
	self.inputs_updated.connect(_on_inputs_changed)
	
	# Begin the selected song...
	load_song(Global.selected_song.resource_uri)
	
	# Setup the tracks
	
	var track_left = Track.instantiate().init(timings.left)
	var track_right = Track.instantiate().init(timings.right)
	var track_up = Track.instantiate().init(timings.up)
	var track_down = Track.instantiate().init(timings.down)
	
	# Setup the tracks
	var interface = get_node("../InterfaceOverlay")
	interface.add_child(track_left)
	interface.add_child(track_right)
	interface.add_child(track_up)
	interface.add_child(track_down)
	ui_tracks.append([Direction.LEFT, track_left])
	ui_tracks.append([Direction.RIGHT, track_right])
	ui_tracks.append([Direction.UP, track_up])
	ui_tracks.append([Direction.DOWN, track_down])
	
	$AudioStreamPlayer.play()
	track_start_time = Time.get_ticks_msec()

func _process(delta):
	var elapsed_time = get_time_since_track_start()
	for ui_track in ui_tracks:
		ui_track[1].position = Vector2(ui_track[0] * 100, -(float(elapsed_time) / float(8)))

func _input(event):
	if not (event is InputEventKey) or event.is_echo():
		return
		
	if event.is_pressed():
		pressed_keys.append(event.keycode)
	else:
		pressed_keys.erase(event.keycode)
	
	inputs_updated.emit(pressed_keys)
