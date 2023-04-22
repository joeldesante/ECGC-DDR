extends Control

var timestamp_msec = null
var direction = null
var is_hit: bool = false
var hit_offset = null

# returns tuple style array (HFlip: bool, rotated: bool)
func _get_arrow_orientation_from_direction(direction: int):
	if direction == 3: # Right
		return [false, false]
	if direction == 1: # Up
		return [true, true]
	if direction == 2: # Down
		return [false, true]
	if direction == 0: # Left
		return [true, false]
	return [false, false]
	
func _get_time_until_timestamp(elapsed_time: int):
	if timestamp_msec == null: return null
	return timestamp_msec - elapsed_time

func _ready():
	pass

func init(timestamp_msec: int, direction: int):
	self.timestamp_msec = timestamp_msec
	self.direction = direction
	
	var arrow_orientation = _get_arrow_orientation_from_direction(direction)
	$Arrow.flip_h = arrow_orientation[0]
	$Arrow.rotation = deg_to_rad(90) if arrow_orientation[1] else 0
	
	return self

func hit(hit_offset_msec: int):
	if is_hit: return
	is_hit = true
	hit_offset = hit_offset_msec
