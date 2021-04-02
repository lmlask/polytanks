extends MeshInstance

# public variables
export var wheelOffset : Vector3 = Vector3(0,0.62,0)
export var trackThickness : float = 0.15
export var returnSpeed : float = 6.0
export(NodePath) var raycastPath


# private variables
var boneName
var raycast : RayCast
var trackSkeleton : Skeleton
var trackBone
var trackOffset : Vector3 = Vector3(0,trackThickness,0)

func _ready() -> void:
	# setup references
	boneName = self.name
	if get_parent().name == "Left":
		trackSkeleton = get_parent().get_parent().get_parent().get_node("Tracks/panzer_armatureL/skeletonL")
		raycast = get_parent().get_parent().get_parent().get_node("Rays/Left").get_node("Lray" + self.name[6])
	else:
		trackSkeleton = get_parent().get_parent().get_parent().get_node("Tracks/panzer_armatureR/skeletonR")
		raycast = get_parent().get_parent().get_parent().get_node("Rays/Right").get_node("Rray" + self.name[6])
	trackBone = trackSkeleton.find_bone(boneName)
	
	
func _physics_process(delta) -> void:
	# set the wheel position
	if raycast.is_colliding():
		transform.origin.y = (raycast.to_local(raycast.get_collision_point()) + wheelOffset).y
	else:
		transform.origin.y = lerp(transform.origin.y, (raycast.cast_to + wheelOffset).y, returnSpeed * delta)
	# deform the track based on wheel position
	var tbonePos = trackSkeleton.get_bone_global_pose(trackBone)
	tbonePos.origin = trackSkeleton.global_transform.xform_inv(global_transform.origin + trackOffset)
	trackSkeleton.set_bone_global_pose_override(trackBone, tbonePos, 1.0, true)
	
