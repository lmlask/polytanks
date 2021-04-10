extends Spatial

var timer:float = 10.0

func _ready():
	$Pieces.emitting = true
	$Smoke.emitting = true
	timer = max($Pieces.lifetime,$Smoke.lifetime)

func _process(delta):
	if $Pieces.emitting or $Smoke.emitting:
		return
	timer -= delta
	if timer < 0:
		queue_free()
