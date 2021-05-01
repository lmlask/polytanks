extends MeshInstance

var state = "idle"
onready var tween = owner.get_node("Interior/Tween")

func _ready():
	pass

func recoil():
	if (owner.get_node("Interior/TurretInterior/Dynamic/GunRig")) != null:
		owner.get_node("Interior/TurretInterior/Dynamic/GunRig").recoil()
	$projectile_spawner/MuzzleFlash1.restart()
	$projectile_spawner/MuzzleFlash1.emitting = true
	$projectile_spawner/MuzzleFlash2.restart()
	$projectile_spawner/MuzzleFlash2.emitting = true
	$projectile_spawner/MuzzleFlash3.restart()
	$projectile_spawner/MuzzleFlash3.emitting = true
	$projectile_spawner/Smoke.restart()
	$projectile_spawner/Smoke.emitting = true
	$projectile_spawner/OmniLight.visible = true
	$projectile_spawner/OmniLight.light_energy = 8
	if $projectile_spawner/OmniLight.light_energy > 0:
		tween.interpolate_property($projectile_spawner/OmniLight, "light_energy", $projectile_spawner/OmniLight.light_energy, 0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
	tween.interpolate_property(self, "translation:z", translation.z, 1.884, 0.15, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(0.15), "timeout")
	tween.interpolate_property(self, "translation:z", translation.z, 2.286, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
