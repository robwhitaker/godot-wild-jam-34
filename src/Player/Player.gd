extends KinematicBody

const MAX_SPEED := 40.0
const ROTATION_DEGREES := 60.0

const SHOOT_DELAY := 0.25

const DEFAULT_RETICLE_Z := -75.0
const RETICLE_SPEED_MOD := 0.35
const GOAL_DISTANCE_FROM_RETICLE := 200.0

const MAX_HP := 5.0

var hp := MAX_HP
export var is_invincible := false # export for animation player

var velocity := Vector3.ZERO

var move_left_mod := 1.0
var move_right_mod := 1.0
var move_top_mod := 1.0
var move_bottom_mod := 1.0

var shooting := false
var shoot_cooldown := 0.0

var reticle_z := DEFAULT_RETICLE_Z
var reticle_target : Spatial = null

var fire_next := RIGHT_CANNON

onready var vis_notif_left := $VisibilityNotifiers/Left as VisibilityNotifier
onready var vis_notif_right := $VisibilityNotifiers/Right as VisibilityNotifier
onready var vis_notif_top := $VisibilityNotifiers/Top as VisibilityNotifier
onready var vis_notif_bottom := $VisibilityNotifiers/Bottom as VisibilityNotifier

onready var hurtbox := $Hurtbox as Area
onready var carrot_catcher := $CarrotCatcher as Area

onready var ship_front := $Markers/ShipFront as Spatial
onready var projectile_spawn_left := $Markers/ProjectileSpawnLeft
onready var projectile_spawn_right := $Markers/ProjectileSpawnRight

onready var cannon_sfx := $Audio/Cannon as AudioStreamPlayer
onready var damage_sfx := $Audio/Damage as AudioStreamPlayer

onready var reticle := $Reticle as TextureRect
onready var animation_player := $AnimationPlayer
onready var camera := get_viewport().get_camera()

enum {
    RIGHT_CANNON,
    LEFT_CANNON
}

func _ready() -> void:
    # Connect signals
    var _e

    _e = vis_notif_left.connect("camera_exited", self, "_camera_exited_left")
    _e = vis_notif_left.connect("camera_entered", self, "_camera_entered_left")

    _e = vis_notif_right.connect("camera_exited", self, "_camera_exited_right")
    _e = vis_notif_right.connect("camera_entered", self, "_camera_entered_right")

    _e = vis_notif_top.connect("camera_exited", self, "_camera_exited_top")
    _e = vis_notif_top.connect("camera_entered", self, "_camera_entered_top")

    _e = vis_notif_bottom.connect("camera_exited", self, "_camera_exited_bottom")
    _e = vis_notif_bottom.connect("camera_entered", self, "_camera_entered_bottom")

    _e = hurtbox.connect("body_entered", self, "_body_entered_hurtbox")
    _e = carrot_catcher.connect("area_entered", self, "_carrot_entered")

    # Reset things that can get screwed up in the editor by
    # animation players
    is_invincible = false
    $ship.set_visible(true)

    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    reticle.set_position(
        camera.unproject_position(global_transform.origin) - reticle.get_size()/2
    )

    Utils.set_player(self)

func _physics_process(_delta : float) -> void:
    # Get the vector from the ship to the cursor
    var direction_to_reticle := _get_vec_to_reticle(ship_front)

    # Point the ship toward the cursor
    set_rotation_degrees(Vector3(
        direction_to_reticle.y * ROTATION_DEGREES,
        direction_to_reticle.x * -ROTATION_DEGREES,
        0
    ))

    # Apply velocity toward the cursor
    var slowdown = (
        GOAL_DISTANCE_FROM_RETICLE
        / max(_get_2d_distance_to_reticle(), GOAL_DISTANCE_FROM_RETICLE)
    )
    velocity = direction_to_reticle * (MAX_SPEED - MAX_SPEED*slowdown)
    velocity.z = 0

    # Apply movement modifiers, which prevent us from
    # moving off camera
    if velocity.x < 0:
        velocity.x *= move_right_mod
    else:
        velocity.x *= move_left_mod

    if velocity.y < 0:
        velocity.y *= move_bottom_mod
    else:
        velocity.y *= move_top_mod

    # Actually move
    velocity = move_and_slide(velocity)

func _process(delta):
    var reticle_pos := reticle.get_position() + reticle.get_size()/2
    var ray_from := camera.project_ray_origin(reticle_pos)
    var ray_to := ray_from + camera.project_ray_normal(reticle_pos) * 1000
    var space_state := get_world().direct_space_state
    var collision := space_state.intersect_ray(ray_from, ray_to, [self])
    if !collision.empty() && collision.collider.is_in_group("Enemy"):
        reticle_z = collision.collider.global_transform.origin.z
        reticle.set_modulate(Color(1,0,0,1))
        reticle_target = collision.collider
    else:
        reticle_z = DEFAULT_RETICLE_Z
        reticle.set_modulate(Color.white)
        reticle_target = null

    if shoot_cooldown - delta > 0:
        shoot_cooldown -= delta
    elif shooting:
        # Choose which cannon to shoot from
        var projectile_spawn : Spatial
        if fire_next == LEFT_CANNON:
            projectile_spawn = projectile_spawn_left
            fire_next = RIGHT_CANNON
        else:
            projectile_spawn = projectile_spawn_right
            fire_next = LEFT_CANNON

        # Get the direction to the reticle
        var direction_to_reticle := _get_vec_to_reticle(projectile_spawn)

        # Play the firing animation
        get_node("ship/AnimationPlayer").play("Fire")

        # Spawn a firing particle effect
        var explosion : Particles = preload("res://src/Explosion/SmallExplosion.tscn").instance()
        explosion.global_transform.origin = Vector3.ZERO
        explosion.emitting = true
        projectile_spawn.add_child(explosion)

        # Play the cannon sound
        cannon_sfx.play()

        # Spawn a projectile
        var projectile := preload("res://src/Projectile/Cannonball.tscn").instance()
        projectile.direction = direction_to_reticle
        projectile.speed = 100.0
        projectile.tracking_target = reticle_target
        projectile.global_transform = projectile_spawn.global_transform
        owner.add_child(projectile)

        # Put our projectile on cooldown
        shoot_cooldown = SHOOT_DELAY

# Helpers

func _get_reticle_3d_position() -> Vector3:
    return -1 * camera.project_position(
        reticle.get_position() + reticle.get_size()/2,
        reticle_z
    )

func _get_vec_to_reticle(node : Spatial) -> Vector3:
    return node.global_transform.origin.direction_to(_get_reticle_3d_position())

func _get_2d_distance_to_reticle() -> float:
    var ship_pos := camera.unproject_position(global_transform.origin)
    var reticle_pos := Vector2(
        reticle.get_position().x + reticle.get_size().x/2,
        reticle.get_position().y + reticle.get_size().y/2
    )
    return ship_pos.distance_to(reticle_pos)

# Signal handling

func _camera_entered_left(_camera : Camera) -> void:
    move_left_mod = 1.0

func _camera_exited_left(_camera : Camera) -> void:
    move_left_mod = 0.0

func _camera_entered_right(_camera : Camera) -> void:
    move_right_mod = 1.0

func _camera_exited_right(_camera : Camera) -> void:
    move_right_mod = 0.0

func _camera_entered_top(_camera : Camera) -> void:
    move_top_mod = 1.0

func _camera_exited_top(_camera : Camera) -> void:
    move_top_mod = 0.0

func _camera_entered_bottom(_camera : Camera) -> void:
    move_bottom_mod = 1.0

func _camera_exited_bottom(_camera : Camera) -> void:
    move_bottom_mod = 0.0

func _body_entered_hurtbox(body : Node) -> void:
    if body.is_in_group("Enemy") || body.is_in_group("Asteroid"):
        apply_damage(1.0)

func _carrot_entered(carrot : Area) -> void:
    Utils.emit_signal("got_carrot")
    carrot.get_parent().queue_free()

# Event handlers

func _input(event):
    if event is InputEventMouseMotion:
        reticle.set_position(reticle.get_position() + event.relative*RETICLE_SPEED_MOD)

    if event.is_action_pressed("Shoot"):
        shooting = true
    elif event.is_action_released("Shoot"):
        shooting = false

# External functions

func apply_damage(dmg : float) -> void:
    if is_invincible:
        return

    is_invincible = true

    var old_hp := hp
    hp -= dmg
    Utils.emit_signal("player_hp_changed", MAX_HP, old_hp, hp)
    camera.shake()
    damage_sfx.play()
    if hp <= 0.0:
        var explosion : Particles = preload("res://src/Explosion/Explosion.tscn").instance()
        explosion.global_transform = global_transform
        explosion.emitting = true
        owner.add_child(explosion)
        queue_free()
    else:
        # Animation applies invincibility until it is over
        animation_player.play("Shake")
