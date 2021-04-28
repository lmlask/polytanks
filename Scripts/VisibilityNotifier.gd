extends VisibilityNotifier


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() is MeshInstance:
		if get_parent().mesh is Mesh:
			aabb = get_parent().mesh.get_aabb()
		

func _on_VisibilityNotifier_screen_entered():
	if get_parent().has_method("notify"):
		get_parent().notify(true)
	else:
		notify(true)


func _on_VisibilityNotifier_screen_exited():
	if get_parent().has_method("notify"):
		get_parent().notify(false)
	else:
		notify(false)

func notify(vis):
	print("visibility",vis)
	get_parent().visible = vis
	print(get_parent().get_parent().name)
	if get_parent().has_node("StaticBody/CollisionShape"):
		get_parent().get_node("StaticBody/CollisionShape").disabled = !vis #get_node is NOT a good idea, fix it
	
