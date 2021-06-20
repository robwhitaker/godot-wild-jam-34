extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var enemy_hp := 30.0
onready var animation_player := $AnimationPlayer as AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
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
