extends AudioStreamPlayer

func _ready():
	# Start immediately
	play()
	# When the MP3 finishes, fire our callback
	connect("finished", Callable(self, "_on_music_finished"))

func _on_music_finished():
	# Simply restart playback
	play()
