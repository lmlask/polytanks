extends MeshInstance

var state = "idle"

func _ready():
	pass

func _process(delta):
	if state == "back":
		translation.z = 1.884
		state = "return"
		
	elif state == "return":
		if translation.z >= 2.286:
			translation.z = 2.286
			state = "idle"
		else:
			translation.z = lerp(translation.z, 2.3, delta*3)
			if $projectile_spawner/OmniLight.light_energy > 0:
				$projectile_spawner/OmniLight.light_energy -= 1
				

func recoil():
	if state == "idle":
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
		state = "back"
		if (owner.get_node("Interior/TurretInterior/Dynamic/GunRig")) != null:
			owner.get_node("Interior/TurretInterior/Dynamic/GunRig").recoil()
