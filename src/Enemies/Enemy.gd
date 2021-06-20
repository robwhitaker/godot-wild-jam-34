extends KinematicBody

export var enemy_hp := 10.0

onready var animation_player := $AnimationPlayer as AnimationPlayer

func apply_damage(dmg : float) -> void:
    enemy_hp -= dmg
    if enemy_hp <= 0.0:
        var root : Spatial = Utils.get_scene_root() as Spatial
        var explosion : Particles = preload("res://src/Explosion/Explosion.tscn").instance()
        explosion.global_transform = global_transform
        explosion.emitting = true
        root.add_child(explosion)
        queue_free()
    else:
        animation_player.play("Shake")
