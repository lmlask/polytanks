extends Node
class_name Painter

var img = Image.new()
var tex = ImageTexture.new()
var envimg = Image.new()
var envtex = ImageTexture.new()
var line:Array
onready var FlatG = $FlatGeometry
onready var LineG = $LineGeometry
onready var AreaCN = $ControlNodes
onready var CN = $ControlNode
var selected_handle
var move_speed = 20
signal reload_area

func _ready():
	img.create(2048,2048,false,Image.FORMAT_RGBA8)
	img.fill(Color(0,0,0,0))
	tex.create_from_image(img)
	img.lock()
	envimg.create(2048,2048,false,Image.FORMAT_RGBA8)
	envimg.fill(Color(0,0,0,0))
	envtex.create_from_image(envimg)
	envimg.lock()
	R.Editor.connect("editor_state",self,"set_visible")
	

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
#	if line.size() == 1:
#		a.x = clamp(a.x,line[0].owner.translation.x,line[0].owner.translation.x+1023.9)
#		a.z = clamp(a.z,line[0].owner.translation.z,line[0].owner.translation.z+1023.9)
#	var node = R.Map.terrainNodes[R.pos2grid(a)]
#	print(node)
	line.append(a)
#	print(line)
	if line.size() == 2:
		line.append(50)
		var ut = OS.get_unix_time()
		R.ManMap.areas[ut] = line.duplicate()
		line.clear()
		process_road(ut,true)

func handle_select(handle):
	if selected_handle:
		update_area(selected_handle)
	selected_handle = handle.get_parent()
	update_area(selected_handle)
	
func _input(event):
	if R.Editor.paint and R.Editor.enabled and not R.Editor.paintPanel.visible:
		if event is InputEventKey:
			if Input.is_action_just_released("ui_accept"):
				update_area(selected_handle)
				selected_handle = null
				get_tree().set_input_as_handled()
			if Input.is_key_pressed(KEY_X):
				delete_area(selected_handle)
				selected_handle = null
				get_tree().set_input_as_handled()
			if Input.is_key_pressed(KEY_R):
				refresh_area()
				get_tree().set_input_as_handled()
			if Input.is_key_pressed(KEY_O):
				emit_signal("reload_area")
			
func refresh_area():
	R.load_image(R.ManMap.map)
	for i in R.ManMap.areas:
		process_road(i,false)
	emit_signal("reload_area")


func delete_area(handle):
	FlatG.clear()
	LineG.clear()
	var aid = handle.get_meta("AreaID")
	R.ManMap.areas.erase(aid)
	for i in AreaCN.get_children():
		print(aid)
		if i.get_meta("AreaID") == aid:
			i.queue_free()
	print("Areas", R.ManMap.areas)

func update_area(handle):
	var aid = handle.get_meta("AreaID")
	var cid = handle.get_meta("ControlID")
	print("update %s %s" % [aid, cid])
	if cid < 2:
		R.ManMap.areas[aid][cid] = handle.global_transform.origin
	if cid == 2:
		var G = Geometry
		var p = G.get_closest_point_to_segment(handle.global_transform.origin,R.ManMap.areas[aid][0],R.ManMap.areas[aid][1])
		R.ManMap.areas[aid][2] = handle.global_transform.origin.distance_to(p)
	process_road(aid,false)
#	handle.owner.update_handle(handle)
	

func _process(delta):
	if selected_handle and not GameState.mouseHidden:
		selected_handle.transform.origin -= selected_handle.transform.basis.z * R.Editor.move.z * delta * move_speed
		selected_handle.transform.origin -= selected_handle.transform.basis.x * R.Editor.move.x * delta * move_speed
		selected_handle.transform.origin -= selected_handle.transform.basis.y * R.Editor.move.y * delta * move_speed

func process_road(i,new):
	
	var line = R.ManMap.areas[i]
#	line[0] = line[0]
#	line[1] = line[1]
	if new:
		var CN1 = CN.duplicate()
		var CN2 = CN.duplicate()
		CN1.set_meta("AreaID", i)
		CN1.set_meta("ControlID", 0)
		CN2.set_meta("AreaID", i)
		CN2.set_meta("ControlID", 1)
		AreaCN.add_child(CN1)
		AreaCN.add_child(CN2)
		CN1.translation = line[0]
		CN2.translation = line[1]
		CN1.show()
		CN2.show()
	var G = Geometry
#	var node = R.Map.terrainNodes[Vector3(0,0,0)]
	var line_vec = (line[1]-line[0]).normalized()
#	var dist = line[0].distance_to(line[1])
	var tang = Transform.looking_at(line_vec,Vector3.UP).basis.x
	var rs1 = line[0]+tang*line[2]
	var rs2 = line[0]-tang*line[2]
	var re1 = line[1]+tang*line[2]
	var re2 = line[1]-tang*line[2]
	var area:PoolVector3Array
	area = [rs2,rs1,re1,re2]
	
	if new:
		var CN3 = CN.duplicate()
		CN3.set_meta("AreaID", i)
		CN3.set_meta("ControlID", 2)
		AreaCN.add_child(CN3)
		CN3.translation = (line[0]+line[1])/2+tang*line[2]
		CN3.show()

	FlatG.clear()
	FlatG.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	FlatG.add_vertex(rs1)
	FlatG.add_vertex(rs2)
	FlatG.add_vertex(re1)
	FlatG.add_vertex(re2)
	FlatG.end()
	LineG.clear()
	LineG.begin(Mesh.PRIMITIVE_LINES)
	for p in area:
		LineG.add_vertex(rs1)
		LineG.add_vertex(re1)
		LineG.add_vertex(rs2)
		LineG.add_vertex(re2)
		LineG.add_vertex(rs1)
		LineG.add_vertex(rs2)
		LineG.add_vertex(re1)
		LineG.add_vertex(re2)
		
		
	LineG.end()
	
#	if road_rect.size() == 6:
#		road_rect.remove(0)
#		road_rect.remove(0)
	#does not belong here, for POC
	var rect:PoolVector2Array
	rect.append(R.v3xz(area[0])/R.ManMap.map_size+Vector2(1024,1024))
	rect.append(R.v3xz(area[1])/R.ManMap.map_size+Vector2(1024,1024))
	rect.append(R.v3xz(area[2])/R.ManMap.map_size+Vector2(1024,1024))
	rect.append(R.v3xz(area[3])/R.ManMap.map_size+Vector2(1024,1024))
	var start = (rect[0]+rect[1])/2
	var end = (rect[2]+rect[3])/2
#	rect.append(Vector2(road_rect[1].x,road_rect[1].z))
#	var rect1 = G.offset_polygon_2d(rect,20)
	if not G.is_polygon_clockwise(rect):
		print("*** not clockwise fix it")
		var t = rect[0]
		rect[0] = rect[1]
		rect[1] = t
	if not G.is_polygon_clockwise(rect):
		print("***Potential problem not fixed")
#	else:
#		print("good")
	var size = R.heightMap.get_size()
	
	var col = sqrt(line[0].y/200)/1.75
	var c1 = Color(col,col,col,1)
	col = sqrt(line[1].y/200)/1.75
	var c2 = Color(col,col,col,1)
	
	var d2 = start.distance_to(end)
	for x in range(size.x):
		for y in range(size.y):
			var imgPoint = Vector2(x,y)
			if G.is_point_in_polygon(imgPoint,rect):
				var point = G.get_closest_point_to_segment_2d(imgPoint,start,end)
				var d1 = start.distance_to(point)
				R.heightMap.set_pixelv(imgPoint,lerp(c1,c2,d1/d2))
	
	return
#	var mesh = node.get_node("Tile").mesh.duplicate()
#	var mdt = MeshDataTool.new()
#	mdt.create_from_surface(mesh, 0)
#	LineG.clear()
#	for i in range(mdt.get_edge_count()):
#		var e0 = mdt.get_edge_vertex(i, 0)
#		var e1 = mdt.get_edge_vertex(i, 1)
#		var v0 = mdt.get_vertex(e0)
#		var v1 = mdt.get_vertex(e1)
#		var point = {}
#
#		for z in range(2):
#			for j in [[rs1,re1],[rs2,re2],[rs1,rs2],[re1,re2]]:
#				if G.segment_intersects_segment_2d(R.v3xz(v0),R.v3xz(v1),R.v3xz(j[0]),R.v3xz(j[1])):
#					var y = G. get_closest_points_between_segments(v0,v1,j[0],j[1])[1].y
#					v0 = Vector3(v0.x,y,v0.z)
#					v1 = Vector3(v1.x,y,v1.z)
#					mdt.set_vertex(e0,v0)
#					mdt.set_vertex(e1,v1)
#
#					LineG.begin(Mesh.PRIMITIVE_LINES)
#					LineG.add_vertex(v0+node.translation)
#					LineG.add_vertex(v1+node.translation)
#					LineG.end()
#		for z in range(3):
#			if G.is_point_in_polygon(R.v3xz(v0),rect) or G.is_point_in_polygon(R.v3xz(v1),rect):
#				var y0 = G.get_closest_point_to_segment(v0,line[0],line[1]).y
#				var y1 = G.get_closest_point_to_segment(v1,line[0],line[1]).y
#				v0 = Vector3(v0.x,y0,v0.z)
#				v1 = Vector3(v1.x,y1,v1.z)
#				mdt.set_vertex(e0,v0)
#				mdt.set_vertex(e1,v1)
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
			
#	mesh.surface_remove(0)
#	mdt.commit_to_surface(mesh)
#	node.create_tile_mesh(mesh,false)
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
	
func set_visible(i):
	FlatG.visible = i
	LineG.visible = i
	for n in AreaCN.get_children():
		n.visible = i
