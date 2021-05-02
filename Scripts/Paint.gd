extends Node


var img = Image.new()
var tex = ImageTexture.new()
var road = []
onready var IG = $ImmediateGeometry
var prev = []

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
	road.append(a+Vector3(0,0.1,0))
	if road.size() == 2:
		var road_vec = (road[1]-road[0]).normalized()
		var dist = int(road[0].distance_to(road[1]))
		var tang = Transform.IDENTITY.looking_at(road_vec,Vector3.UP).basis.x
#		var tang = Vector3(road_vec.z,road_vec.y,road_vec.x)
#		IG.clear()
		IG.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		if prev:
			for j in prev:
				IG.add_vertex(prev[0])
				IG.add_vertex(prev[1])
		IG.add_vertex(R.FloorFinder.floor_at_point(road[0]+tang*5,0.2))
		IG.add_vertex(R.FloorFinder.floor_at_point(road[0]-tang*5,0.2))
		for i in range(0,dist,5):
			IG.add_vertex(R.FloorFinder.floor_at_point(road[0]+tang*5+road_vec*i,0.2))
			IG.add_vertex(R.FloorFinder.floor_at_point(road[0]-tang*5+road_vec*i,0.2))
		IG.add_vertex(R.FloorFinder.floor_at_point(road[0]+tang*5+road_vec*dist,0.2))
		IG.add_vertex(R.FloorFinder.floor_at_point(road[0]-tang*5+road_vec*dist,0.2))
		prev = []
		prev.append(R.FloorFinder.floor_at_point(road[0]+tang*5+road_vec*(dist-1),0.2))
		prev.append(R.FloorFinder.floor_at_point(road[0]-tang*5+road_vec*(dist-1),0.2))
		IG.end()
		road.pop_front()

func update_texture():
	img.unlock()
	tex.create_from_image(img)
	get_tree().call_group("terrain","set_paint")
#	$TextureRect.texture = tex
	img.lock()
