extends Spatial

var enabled = false

func _ready():
	set_process(false)
	set_process_input(false)

func _input(event):
	if not event.is_action_pressed("ui_cancel"): #only exists to not handle showing mouse so you can exit game
		get_tree().set_input_as_handled()
	if event.is_action_pressed("F3") and not event.echo and enabled:
		enabled = false
		set_process(enabled)
		set_process_input(enabled)
		GameState.CamActive._cam.current = true #would imply _cam is consistant for all cams
		return
	if event is InputEventMouseMotion:
#		rotate_y(event.relative.x/100.0)
		rotate(Basis.IDENTITY.y, -event.relative.x/100.0)
		rotation.x = clamp(rotation.x - event.relative.y /100.0, -PI/2, PI/2)
#		rotate(transform.basis.x, -event.relative.y/100.0)
		
	
func _unhandled_key_input(event): #Trying something different
	if event.is_action_pressed("F3") and not event.echo and not enabled:
		print("F3 pressed")
		enabled = true
		set_process(enabled)
		set_process_input(enabled)
		GameState.hide_mouse()
		$Camera.current = true
		global_transform = GameState.CamActive._cam.global_transform #ehhhh _cam?
