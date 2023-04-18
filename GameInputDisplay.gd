extends Label

var pressed_keys = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey and not event.is_echo():
		if event.is_pressed():
			pressed_keys.append(event.keycode)
		else:
			pressed_keys.erase(event.keycode)
	print("Current Keys Pressed: " + str(pressed_keys))	
