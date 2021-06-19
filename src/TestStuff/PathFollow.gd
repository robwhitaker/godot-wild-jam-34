extends PathFollow

const SPEED := 10.0

func _physics_process(delta):
    offset += delta * SPEED
