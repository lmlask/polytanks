extends Node

onready var turret = owner.get_node("Visuals/Turret")
onready var barrel = owner.get_node("Visuals/Turret/Gun/Barrel")
onready var clip = owner.get_node("Visuals/Turret/Gun/AmmoStrip")
onready var muzzleSound = owner.get_node("Visuals/Turret/Gun/MuzzleSound")
onready var flash = owner.get_node("Visuals/Turret/Gun/Barrel/ProjectileSpawner/MuzzleFlash")

export var shell_scene = preload("res://Projectiles/PanzerIV/Projectile.tscn")
export var shellSpawnerPath : String = "Visuals/Turret/Gun/Barrel/ProjectileSpawner"

var shellSpawner

#export var shell_scene = preload("res://Projectiles/PanzerIV/Projectile.tscn")


func _ready():
	shellSpawner = owner.get_node(shellSpawnerPath)


var traverse_multiplier = 5 
var elevation_multiplier = 6 

var dir : float = 0
var eledir : float = 0

var turn_speed_tgt = 0
var turn_speed = 0
var ele_speed_tgt = 0
var ele_speed = 0
var accel_speed = 0.2
var timer:float = 0.0

var was_playing = false
var ele_was_playing = false

var loaded = true
var can_fire = true

func _process(delta):
	#Turn turret
	turn_speed_tgt = traverse_multiplier * dir * 0.1
	turn_speed = lerp(turn_speed, turn_speed_tgt, (accel_speed*0.1))
	turret.rotate(Vector3(0, 1, 0), turn_speed*delta)
	
	#Elevate
	ele_speed_tgt = eledir * elevation_multiplier * 0.05
	ele_speed = lerp(ele_speed, ele_speed_tgt, 0.1)
	turret.get_node("Gun").rotate(Vector3(1, 0, 0), ele_speed*delta)
	
	#Clamp
	turret.get_node("Gun").rotation_degrees.x = clamp(turret.get_node("Gun").rotation_degrees.x, -45, 20) 
	
	if owner.auto:
		timer += delta #for auto firing during intro
		var firetime = randf()
		if timer > firetime:
			timer -= firetime
			fire()

func fire(id = 0, number = 0, host = false):
	
	
	if clip.hasAmmo():
		can_fire = false
		muzzleSound.play()
		flash.restart()
		clip.fireOne()
		#spawning shell
		var shell = shell_scene.instance()
		shell.name = str(id,"-",number)
		shell.host = host
		add_child(shell)
		shell.global_transform = shellSpawner.global_transform
		#barrel recoil anim
		barrel.recoil()
		var point = barrel.get_node("ProjectileSpawner").global_transform.origin
		owner.apply_impulse(owner.global_transform.basis.xform(owner.to_local(point)), Vector3(0, 5, 0))
		yield(get_tree().create_timer(0.25), "timeout")
		can_fire = true

	
