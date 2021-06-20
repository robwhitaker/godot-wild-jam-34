extends Particles

onready var audio_player := $AudioStreamPlayer as AudioStreamPlayer3D

func _ready():
    if audio_player != null:
        audio_player.play()
    yield(get_tree().create_timer(1.0), "timeout")
    queue_free()
