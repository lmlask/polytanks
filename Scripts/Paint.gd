extends Node


var img = Image.new()
var tex = ImageTexture.new()

func _ready():
	img.create(2048,2048,false,Image.FORMAT_RGBA8)
	img.fill(Color(0,0,0,0))
	tex.create_from_image(img)
	img.lock()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func paint(pos,pressure:float):
	var imgpos = Vector2(pos.x,pos.z)/4.5+Vector2(1024,1024)
#	print("Painting pos:",imgpos, pressure)
	for x in range(-1,1):
		for y in range(-1,1):
			var col = img.get_pixelv(imgpos+Vector2(x,y))
			col += Color(0,0,0,0.1)
			img.set_pixelv(imgpos+Vector2(x,y),col)

func update_texture():
	img.unlock()
	tex.create_from_image(img)
	get_tree().call_group("terrain","set_paint")
#	$TextureRect.texture = tex
	img.lock()
