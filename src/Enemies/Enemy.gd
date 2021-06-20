extends KinematicBody

const MAX_ATTACK_ANGLE := 2.5
const MAX_ATTACK_DISTANCE := 75.0

export var enemy_hp := 3.0
export var attack_cooldown := 0.1
export var carrot_drop := 3

var cooldown := 0.0

onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var snoot := $Markers/Snoot as Spatial
onready var camera := get_viewport().get_camera()

func _process(delta):
    cooldown -= delta

    var player := Utils.get_player() as KinematicBody
    var player_pos : Vector3
    if player != null && is_instance_valid(player):
        player_pos = player.global_transform.origin
    else:
        return

    if cooldown <= 0.0:
        var a1 := player_pos.direction_to(snoot.global_transform.origin)
        var a2 := global_transform.origin.direction_to(snoot.global_transform.origin)
        var distance_to_player := global_transform.origin.distance_to(player_pos)
        if ( a1.angle_to(a2) >= MAX_ATTACK_ANGLE
          && distance_to_player <= MAX_ATTACK_DISTANCE
           ):
            # Spawn a projectile
            var projectile := preload("res://src/Projectile/EnemyProjectile.tscn").instance()
            projectile.direction = snoot.global_transform.origin.direction_to(player_pos)
            projectile.speed = 30.0
            projectile.global_transform = snoot.global_transform
            Utils.get_scene_root().add_child(projectile)
            cooldown = attack_cooldown

func apply_damage(dmg : float) -> void:
    enemy_hp -= dmg
    if enemy_hp <= 0.0:
        var root : Spatial = Utils.get_scene_root() as Spatial
        var explosion : Particles = preload("res://src/Explosion/Explosion.tscn").instance()
        explosion.global_transform = global_transform
        explosion.emitting = true
        root.add_child(explosion)

        _spawn_carrots(carrot_drop)

        queue_free()
    else:
        animation_player.play("Shake")

func _spawn_carrots(amt : int) -> void:
    while amt > 0:
        var direction := Vector3.ZERO
        direction.x = rand_range(-1, 1)
        direction.y = rand_range(-1, 1)
        var carrot := preload("res://src/Carrot/Carrot.tscn").instance() as Spatial
        carrot.global_transform = global_transform
        carrot.velocity = direction * 30
        Utils.get_scene_root().add_child(carrot)
        amt -= 1
