extends Control

var timings = []
var speed_divisor = 8

func init(timings: Array,):
	self.timings = timings
	
	for timing in timings:
		print(timing)
		timing.position = Vector2(0, timing.timestamp_msec / speed_divisor)
		self.add_child(timing)
	
	return self
