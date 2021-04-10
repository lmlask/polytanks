extends CanvasLayer

onready var Volume = $Panel/Volume
onready var Wind = $Panel/Wind
onready var Speed = $Panel/Speed
onready var Master = AudioServer.get_bus_index("Master")
const SettingsFile = "user://Settings.dat"
var data = {}

func _ready():
	$Panel.hide()
	load_settings()


func _on_Volume_value_changed(value):
	AudioServer.set_bus_volume_db(Master, value)

func _on_Save_pressed():
	data = {}
	data["Vol"] = Volume.value
	data["Wind"] = Wind.wind_vector
	data["Speed"] = Speed.value
	var settings = File.new()
	settings.open(SettingsFile, File.WRITE)
	settings.store_var(data)
	settings.close()

func _input(event):
	if Input.is_action_just_pressed("F1"):
		$Panel.visible = !$Panel.visible
		if $Panel.visible: #merge into a function
			GameState.show_mouse()
		else:
			GameState.hide_mouse()
			

func load_settings():
	var settings = File.new()
	if not settings.file_exists(SettingsFile):
		return
	settings.open(SettingsFile, File.READ)
	data = settings.get_var()
	if data.has("Vol"):
		AudioServer.set_bus_volume_db(Master, data.Vol)
		Volume.value = data.Vol
	if data.has("Wind"):
		Wind.wind_vector = data.Wind
		Wind._ready()
		GameState.wind_vector = data.Wind
	if data.has("Speed"):
		Speed.value = data.Speed
		GameState.speed = data.Speed
	settings.close()



func _on_Speed_value_changed(value):
	GameState.speed = value
