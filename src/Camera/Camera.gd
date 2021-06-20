extends Camera

onready var animation_player = $AnimationPlayer as AnimationPlayer

func shake() -> void:
    animation_player.play("Shake")
