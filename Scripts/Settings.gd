extends CanvasLayer

onready var Volume = $Panel/Volume
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
	var settings = File.new()
	settings.open(SettingsFile, File.WRITE)
	settings.store_var(data)
	settings.close()

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_F1 and event.pressed and not event.echo:
			$Panel.visible = !$Panel.visible

func load_settings():
	var settings = File.new()
	if not settings.file_exists(SettingsFile):
		return
	settings.open(SettingsFile, File.READ)
	data = settings.get_var()
	AudioServer.set_bus_volume_db(Master, data.Vol)
	Volume.value = data.Vol
	settings.close()
