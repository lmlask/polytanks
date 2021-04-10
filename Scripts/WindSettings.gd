extends Panel

var wind_pos = rect_size/2
var guide = false
var wind_vector = Vector2.ZERO


func _ready():
	wind_pos = wind_vector+rect_size/2
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	
func _draw():
	if guide:
		draw_line(rect_size/2,get_global_mouse_position()-rect_position,Color.white)
	draw_circle(wind_pos,5,Color.white)
	draw_line(rect_size/2,wind_pos,Color.white)


func _on_Wind_mouse_entered():
	guide = true
	set_process(true)


func _on_Wind_mouse_exited():
	guide = false
	set_process(false)
	update()
	wind_vector = wind_pos-rect_size/2
	GameState.wind_vector = wind_vector
	GameState.send_game_data()

func _on_Wind_gui_input(event):
	if event is InputEventMouseButton:
		wind_pos = get_global_mouse_position()-rect_position
