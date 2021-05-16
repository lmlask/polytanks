extends RigidBody
class_name TankBase

var auto = true
var VehicleMan = null
var prev_xform:Transform
var next_xform:Transform
var weight_xform = 0.0
var external_only = true

func _process(delta):
#	role = $RoleController.role
	if auto:
		if (transform.basis.y.y < 0 and transform.origin.y < 2) or translation.distance_to(Vector3(0,0,0)) > 500:
			translation = Vector3(0,0,0)
			VehicleMan.reset_tank(self)
#	elif GameState.role == GameState.Role.Gunner and GameState.roles.has(GameState.Role.Driver):
	elif (not GameState.role == GameState.Role.Driver and not GameState.DriverID[GameState.tank] == get_tree().get_network_unique_id()) or external_only:
		weight_xform += delta * 1/0.1
		transform = prev_xform.interpolate_with(next_xform, weight_xform)

func next_transform(t:Transform):
#	transform = t
	weight_xform = 0.0
	next_xform = t
	prev_xform = transform
