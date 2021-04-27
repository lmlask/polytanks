extends Node

var MMIs = {} #key = ID, 0=MMI node
var MMI_items = {} #key = location, 0=instance id

func _ready():
	return #Too be changed
#	for i in R.EnvItems:
#		var MMI = MultiMeshInstance.new()
#		MMI.multimesh = MultiMesh.new()
#		MMI.multimesh.transform_format = MultiMesh.TRANSFORM_3D
#		MMI.multimesh.instance_count = 9999
#		MMI.multimesh.visible_instance_count = 0
#		MMI.multimesh.mesh = R.EnvItems[i][0].instance().mesh
#		MMIs[i] = [MMI]
#		add_child(MMI)

func paint(c_pos):
	return #Too be changed
#	for i in range(25):
#		var pos = c_pos + Vector3(rand_range(-100,100),0,rand_range(-100,100))
#		pos = R.FloorFinder.floor_at_point(pos)
#		var rn = int(rand_range(0,MMIs.size()))
#		MMIs[rn][0].multimesh.set_instance_transform(MMIs[rn][0].multimesh.visible_instance_count,Transform(Basis.IDENTITY,pos))
#		MMIs[rn][0].multimesh.visible_instance_count += 1
