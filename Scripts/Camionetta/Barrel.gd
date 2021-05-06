extends MeshInstance

onready var tween = owner.get_node("Interior/Tween")

func recoil():
	tween.interpolate_property(self, "translation:z", translation.z, -0.04, 0.1, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(0.1), "timeout")
	tween.interpolate_property(self, "translation:z", translation.z, 0.031, 0.15, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
