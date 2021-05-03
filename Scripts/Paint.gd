extends Node


var img = Image.new()
var tex = ImageTexture.new()
var road = []
onready var IG = $ImmediateGeometry
var road_rect:PoolVector3Array

func _ready():
	img.create(2048,2048,false,Image.FORMAT_RGBA8)
	img.fill(Color(0,0,0,0))
	tex.create_from_image(img)
	img.lock()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func paint(pos):
	var imgpos = Vector2(pos.x,pos.z)/4.5+Vector2(1024,1024)
#	print("Painting pos:",imgpos, pressure)
	for x in range(-1,1):
		for y in range(-1,1):
			var col = img.get_pixelv(imgpos+Vector2(x,y))
			var temp = (R.Editor.PaintColor.color-col)/100
			col += Color(max(temp.r,0.005)*sign(temp.r),max(temp.g,0.005)*sign(temp.g),max(temp.b,0.005)*sign(temp.b),max(temp.a,0.005)*sign(temp.a))
			col += temp
			img.set_pixelv(imgpos+Vector2(x,y),col)

func road(a,b):
	road.append(a)
	
	if road.size() == 2:
		var road_vec = (road[1]-road[0]).normalized()
		var dist = road[0].distance_to(road[1])
		var tang = Transform.looking_at(road_vec,Vector3.UP).basis.x
		var y = R.FloorFinder.floor_at_point(road[0]).y
		var p1 = road[0]+tang*5
		var p2 = road[0]-tang*5
		road_rect.append(Vector3(p1.x,y,p1.z))
		road_rect.append(Vector3(p2.x,y,p2.z))
		for i in range(0,dist,4): #follow ground
			y = R.FloorFinder.floor_at_point(road[0]+road_vec*i).y
			p1 = road[0]+tang*5+road_vec*i
			p2 = road[0]-tang*5+road_vec*i
			road_rect.append(Vector3(p1.x,y,p1.z))
			road_rect.append(Vector3(p2.x,y,p2.z))
		y = R.FloorFinder.floor_at_point(road[0]+road_vec*dist).y
		p1 = road[0]+tang*5+road_vec*dist
		p2 = road[0]-tang*5+road_vec*dist
		road_rect.append(Vector3(p1.x,y,p1.z))
		road_rect.append(Vector3(p2.x,y,p2.z))
		add_road()
		road.pop_front()

func add_road():
	var G = Geometry
	IG.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for p in road_rect:
		IG.add_vertex(p)
	IG.end()
	
#	if road_rect.size() == 6:
#		road_rect.remove(0)
#		road_rect.remove(0)
	#does not belong here, for POC
	var rect:PoolVector2Array
	var node = R.Map.terrainNodes[Vector3(0,0,0)]
	var offset = R.v3xz(node.translation)
#	rect.append(R.v3xz(road_rect[0])-offset)
#	rect.append(R.v3xz(road_rect[1])-offset)
#	rect.append(R.v3xz(road_rect[road_rect.size()-2])-offset)
#	rect.append(R.v3xz(road_rect[road_rect.size()-1])-offset)
#	rect.append(Vector2(road_rect[1].x,road_rect[1].z))
#	var rect1 = G.offset_polygon_2d(rect,20)
#	if not G.is_polygon_clockwise(rect):
#		print("problem, not clockwise")
#		var t = rect[0]
#		rect[0] = rect[1]
#		rect[1] = t
#	if not G.is_polygon_clockwise(rect):
#		print("problem not fixed")
#	else:
#		print("good")
#	print(rect)
	
	var roadmesh = node.get_node("Tile").mesh.duplicate()
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(roadmesh, 0)
	for i in range(mdt.get_edge_count()):
		var e0 = mdt.get_edge_vertex(i, 0)
		var e1 = mdt.get_edge_vertex(i, 1)
		var v0 = mdt.get_vertex(e0)
		var v1 = mdt.get_vertex(e1)
		var point = {}
		for j in range(road_rect.size()-2):
			var p = G.segment_intersects_triangle(v0,v1,road_rect[j]-node.translation,road_rect[j+1]-node.translation,road_rect[j+2]-node.translation)
			if p:
				print(p.y," - ",v0.y," - ",v1.y)
				p=p.y-0.5
				if not point.has(e0):
					v0 = Vector3(v0.x,p,v0.z)
					point[e0] = v0
				else:
					if p < point[e0].y:
						v0 = Vector3(v0.x,p,v0.z)
						point[e0] = v0
				if not point.has(e1):
					v1 = Vector3(v1.x,p,v1.z)
					point[e1] = v1
				else:
					if p < point[e1].y:
						v1 = Vector3(v1.x,p,v1.z)
						point[e1] = v1
			p = G.segment_intersects_triangle(v1,v0,road_rect[j]-node.translation,road_rect[j+1]-node.translation,road_rect[j+2]-node.translation)
			if p:
				print(p.y," - ",v0.y," - ",v1.y)
		for j in point:
			mdt.set_vertex(j,point[j])
		
			
		
		
#		if G.segment_intersects_segment_2d(R.v3xz(v0),R.v3xz(v1),rect[0],rect[2]) or G.segment_intersects_segment_2d(R.v3xz(v0),R.v3xz(v1),rect[1],rect[3]):
#			var y0 = G.get_closest_point_to_segment(v0,road_rect[0]-node.translation,road_rect[road_rect.size()-2]-node.translation).y
#			var y1 = G.get_closest_point_to_segment(v1,road_rect[0]-node.translation,road_rect[road_rect.size()-2]-node.translation).y
#			v0 = Vector3(v0.x,y0,v0.z)
#			v1 = Vector3(v1.x,y1,v1.z)
#			mdt.set_vertex(e0,v0)
#			mdt.set_vertex(e1,v1)
#		if G.is_point_in_polygon(R.v3xz(v0),rect) or G.is_point_in_polygon(R.v3xz(v1),rect):
#			var y0 = G.get_closest_point_to_segment(v0,road_rect[0]-node.translation,road_rect[road_rect.size()-2]-node.translation).y
#			var y1 = G.get_closest_point_to_segment(v1,road_rect[0]-node.translation,road_rect[road_rect.size()-2]-node.translation).y
#			v0 = Vector3(v0.x,y0,v0.z)
#			v1 = Vector3(v1.x,y1,v1.z)
#			mdt.set_vertex(e0,v0)
#			mdt.set_vertex(e1,v1)
#
#		if G.segment_intersects_segment_2d(R.v3xz(v0),R.v3xz(v1),rect[0],rect[1]):
#			v0 = Vector3(v0.x,(road_rect[0]-node.translation).y,v0.z)
#			v1 = Vector3(v1.x,(road_rect[0]-node.translation).y,v1.z)
#			mdt.set_vertex(e0,v0)
#			mdt.set_vertex(e1,v1)
#		if G.segment_intersects_segment_2d(R.v3xz(v0),R.v3xz(v1),rect[2],rect[3]):
#			v0 = Vector3(v0.x,(road_rect[road_rect.size()-2]-node.translation).y,v0.z)
#			v1 = Vector3(v1.x,(road_rect[road_rect.size()-2]-node.translation).y,v1.z)
#			mdt.set_vertex(e0,v0)
#			mdt.set_vertex(e1,v1)
	roadmesh.surface_remove(0)
	mdt.commit_to_surface(roadmesh)
	node.create_tile_mesh(roadmesh,false)
#	node.get_node("Tile").mesh = roadmesh
	
#	road_rect[0] = road_rect[road_rect.size()-2]
#	road_rect[1] = road_rect[road_rect.size()-1]
	road_rect.resize(0)
	
func update_texture():
	img.unlock()
	tex.create_from_image(img)
	get_tree().call_group("terrain","set_paint")
#	$TextureRect.texture = tex
	img.lock()
