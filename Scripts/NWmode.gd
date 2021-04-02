extends Label

func _process(_delta):
	if not GameState.mode == null: #work around
		text = "Network Mode: %s" % GameState.Mode.keys()[GameState.mode]
	
