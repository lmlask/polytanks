extends Node
class_name Painter

var img = Image.new()
var tex = ImageTexture.new()
var envimg = Image.new()
var envtex = ImageTexture.new()
var line = []
onready var FlatG = $FlatGeometry
onready var ControlG = $ControlGeometry
var selected_handle
var move_speed = 20

func _ready():
	img.create(2048,2048,false,Image.FORMAT_RGBA8)
	img.fill(Color(0,0,0,0))
	tex.create_from_image(img)
	img.lock()
	envimg.create(2048,2048,false,Image.FORMAT_RGBA8)
	envimg.fill(Color(0,0,0,0))
	envtex.create_from_image(envimg)
	envimg.lock()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func paint(pos, paintMode):
	var imgpos = Vector2(pos.x,pos.z)/R.ManMap.map_size+Vector2(1024,1024)
#	print("Painting pos:",imgpos, pressure)
	for x in range(-1,1):
		for y in range(-1,1):
			var col = null
			if paintMode == R.Editor.paintModes.TERRAIN:
				col = img.get_pixelv(imgpos+Vector2(x,y))
			if paintMode == R.Editor.paintModes.ENV:
				col = envimg.get_pixelv(imgpos+Vector2(x,y))
			var temp = (R.Editor.PaintColor.color-col)/5
			col += Color(max(temp.r,0.01)*sign(temp.r),max(temp.g,0.01)*sign(temp.g),max(temp.b,0.01)*sign(temp.b),max(temp.a,0.01)*sign(temp.a))
			col += temp
			if paintMode == R.Editor.paintModes.TERRAIN:
				img.set_pixelv(imgpos+Vector2(x,y),col)
			if paintMode == R.Editor.paintModes.ENV:
				envimg.set_pixelv(imgpos+Vector2(x,y),col)

func area(a):
	if line.size() == 1:
		a.x = clamp(a.x,line[0].owner.translation.x,line[0].owner.translation.x+1023.9)
		a.z = clamp(a.z,line[0].owner.translation.z,line[0].owner.translation.z+1023.9)
	var node = R.Map.terrainNodes[R.pos2grid(a)]
	print(node)
	line.append(node.add_handle(a))
	if line.size() == 2:
		node.add_area(line)
		line.clear()

func handle_select(handle):
	if selected_handle:
		update_area(selected_handle)
	selected_handle = handle.get_parent()
	
func _input(event):
	if R.Editor.paint and R.Editor.enabled and not R.Editor.paintPanel.visible:
		if event is InputEventKey:
			if Input.is_action_just_released("ui_accept"):
				update_area(selected_handle)
				selected_handle = null
				get_tree().set_input_as_handled()

func update_area(handle):
	handle.owner.update_handle(handle)
	

func _process(delta):
	if selected_handle and not GameState.mouseHidden:
		selected_handle.transform.origin -= selected_handle.transform.basis.z * R.Editor.move.z * delta * move_speed
		selected_handle.transform.origin -= selected_handle.transform.basis.x * R.Editor.move.x * delta * move_speed
		selected_handle.transform.origin -= selected_handle.transform.basis.y * R.Editor.move.y * delta * move_speed

func add_road(line):
	print("obsolete")
	line[0] = line[0]+R.tilehalf
	line[1] = line[1]+R.tilehalf
	var G = Geometry
	var node = R.Map.terrainNodes[Vector3(0,0,0)]
	var line_vec = (line[1]-line[0]).normalized()
	var dist = line[0].distance_to(line[1])
	var tang = Transform.looking_at(line_vec,Vector3.UP).basis.x
	var rs1 = line[0]+tang*25
	var rs2 = line[0]-tang*25
	var re1 = line[1]+tang*25
	var re2 = line[1]-tang*25
	var area:PoolVector3Array
	area = [rs1,rs2,re1,re2]


	FlatG.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for p in area:
		FlatG.add_vertex(p-R.tilehalf+Vector3(0,0.1,0))
	FlatG.end()
	ControlG.begin(Mesh.PRIMITIVE_LINES)
	for p in area:
		ControlG.add_vertex(rs1-R.tilehalf)
		ControlG.add_vertex(re1-R.tilehalf)
		ControlG.add_vertex(rs2-R.tilehalf)
		ControlG.add_vertex(re2-R.tilehalf)
		
	ControlG.end()
#	return
	
#	if road_rect.size() == 6:
#		road_rect.remove(0)
#		road_rect.remove(0)
	#does not belong here, for POC
	var rect:PoolVector2Array
	rect.append(R.v3xz(area[0]))
	rect.append(R.v3xz(area[1]))
	rect.append(R.v3xz(area[2]))
	rect.append(R.v3xz(area[3]))
#	rect.append(Vector2(road_rect[1].x,road_rect[1].z))
#	var rect1 = G.offset_polygon_2d(rect,20)
	if not G.is_polygon_clockwise(rect):
		var t = rect[0]
		rect[0] = rect[1]
		rect[1] = t
	if not G.is_polygon_clockwise(rect):
		print("***Potential problem not fixed")
#	else:
#		print("good")
#	print(rect)
	
	var mesh = node.get_node("Tile").mesh.duplicate()
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	ControlG.clear()
	for i in range(mdt.get_edge_count()):
		var e0 = mdt.get_edge_vertex(i, 0)
		var e1 = mdt.get_edge_vertex(i, 1)
		var v0 = mdt.get_vertex(e0)
		var v1 = mdt.get_vertex(e1)
		var point = {}
		
		for z in range(2):
			for j in [[rs1,re1],[rs2,re2],[rs1,rs2],[re1,re2]]:
				if G.segment_intersects_segment_2d(R.v3xz(v0),R.v3xz(v1),R.v3xz(j[0]),R.v3xz(j[1])):
					var y = G. get_closest_points_between_segments(v0,v1,j[0],j[1])[1].y
					v0 = Vector3(v0.x,y,v0.z)
					v1 = Vector3(v1.x,y,v1.z)
					mdt.set_vertex(e0,v0)
					mdt.set_vertex(e1,v1)
					
					ControlG.begin(Mesh.PRIMITIVE_LINES)
					ControlG.add_vertex(v0+node.translation)
					ControlG.add_vertex(v1+node.translation)
					ControlG.end()
		for z in range(3):
			if G.is_point_in_polygon(R.v3xz(v0),rect) or G.is_point_in_polygon(R.v3xz(v1),rect):
				var y0 = G.get_closest_point_to_segment(v0,line[0],line[1]).y
				var y1 = G.get_closest_point_to_segment(v1,line[0],line[1]).y
				v0 = Vector3(v0.x,y0,v0.z)
				v1 = Vector3(v1.x,y1,v1.z)
				mdt.set_vertex(e0,v0)
				mdt.set_vertex(e1,v1)
#
#		if G.segment_intersects_segment_2d(R.v3xz(v0),R.v3xz(v1),rect[0],rect[1]):
#			v0 = Vector3(v0.x,(road_rect[0]-node.translation).y,v0.z)
#			v1 = Vector3(v1.x,(road_rect[0]-node.translation).y,v1.z)
#			mdt.set_vertex(e0,v0)
#			mdt.set_vertex(e1,v1)
#		if G.segment_intersects_segment_2d(R.v3xz(v0),R.v3xz(v1),rect[2],rect[3]):
#			v0 = Vector3(v0.x,(road_rect[2]-node.translation).y,v0.z)
#			v1 = Vector3(v1.x,(road_rect[2]-node.translation).y,v1.z)
#			mdt.set_vertex(e0,v0)
#			mdt.set_vertex(e1,v1)
			
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	node.create_tile_mesh(mesh,false)
#	node.get_node("Tile").mesh = roadmesh
	
#	road_rect[0] = road_rect[road_rect.size()-2]
#	road_rect[1] = road_rect[road_rect.size()-1]
#	road_rect.resize(0)

func update_env():
	envimg.unlock()
	envtex.create_from_image(envimg) #needed?
	envimg.lock()
	var node = R.Map.terrainNodes[R.pos2grid(Vector3(0,0,0))]
	node.process_env()
#	get_tree().call_group("terrain","set_paint")
#	$TextureRect.texture = tex
	
	
func update_texture():
	img.unlock()
	tex.create_from_image(img)
	img.lock()
	get_tree().call_group("terrain","set_paint")
#	$TextureRect.texture = tex
	
