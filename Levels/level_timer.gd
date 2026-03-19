extends Label

func _ready() -> void:
	Global.level_time_left_changed.connect(on_level_time_left_changed)

func on_level_time_left_changed(time_left):
	self.text = str(int(time_left)/60) + ":"
	if int(time_left)%60 < 10:
		self.text += str("0")
	self.text += str(int(time_left)%60)
