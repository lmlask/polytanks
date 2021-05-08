extends Spatial

onready var shell_scene = preload("res://Projectiles/Camionetta/20mmAmmo.tscn")
onready var casing_scene = preload("res://Projectiles/Camionetta/20mmCasing.tscn")
onready var tween = owner.get_node("Interior/Tween")

var ammo = 12

func _ready():
	for child in $AmmoStripMesh.get_children():
		var shell = shell_scene.instance()
		child.call_deferred("add_child", shell)

func hasAmmo():
	if ammo > 0:
		return true
	else:
		return false
		
func fireOne():
	#clip anim
	tween.interpolate_property($AmmoStripMesh, "translation:x", $AmmoStripMesh.translation.x, $AmmoStripMesh.translation.x - 0.04, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
	#replace ammo for casing
	var casing = casing_scene.instance()
	$AmmoStripMesh.get_child(-ammo + 12).get_child(0).queue_free()
	$AmmoStripMesh.get_child(-ammo + 12).add_child(casing)
	
	#ammo count
	ammo -= 1
	
	print(ammo)
