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

        _spawn_carrots(15)

        queue_free()
    else:
        animation_player.play("Shake")

func _spawn_carrots(amt : int) -> void:
    while amt > 0:
        var direction := Vector3.ZERO
        direction.x = rand_range(-1, 1)
        direction.y = rand_range(-1, 1)
        direction.z = rand_range(0, 1)
        var carrot := preload("res://src/Carrot/Carrot.tscn").instance() as Spatial
        carrot.global_transform = global_transform
        carrot.velocity = direction * 70
        Utils.get_scene_root().add_child(carrot)
        amt -= 1
