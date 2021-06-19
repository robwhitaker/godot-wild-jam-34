extends KinematicBody

const MAX_SPEED := 40.0
const ROTATION_DEGREES := 60.0

const SHOOT_DELAY := 0.1

const DEFAULT_RETICLE_Z := -75.0
const RETICLE_SPEED_MOD := 0.35
const GOAL_DISTANCE_FROM_RETICLE := 200.0

var velocity := Vector3.ZERO

var move_left_mod := 1.0
var move_right_mod := 1.0
var move_top_mod := 1.0
var move_bottom_mod := 1.0

var shooting := false
var shoot_cooldown := 0.0

var reticle_z := DEFAULT_RETICLE_Z

onready var vis_notif_left := $VisibilityNotifiers/Left as VisibilityNotifier
onready var vis_notif_right := $VisibilityNotifiers/Right as VisibilityNotifier
onready var vis_notif_top := $VisibilityNotifiers/Top as VisibilityNotifier
onready var vis_notif_bottom := $VisibilityNotifiers/Bottom as VisibilityNotifier

onready var reticle := $Reticle as TextureRect
onready var projectile_spawn := $ProjectileSpawn as Spatial
onready var camera := get_viewport().get_camera()

func _ready() -> void:
    var _e
    _e = vis_notif_left.connect("camera_exited", self, "_camera_exited_left")
    _e = vis_notif_left.connect("camera_entered", self, "_camera_entered_left")

    _e = vis_notif_right.connect("camera_exited", self, "_camera_exited_right")
    _e = vis_notif_right.connect("camera_entered", self, "_camera_entered_right")

    _e = vis_notif_top.connect("camera_exited", self, "_camera_exited_top")
    _e = vis_notif_top.connect("camera_entered", self, "_camera_entered_top")

    _e = vis_notif_bottom.connect("camera_exited", self, "_camera_exited_bottom")
    _e = vis_notif_bottom.connect("camera_entered", self, "_camera_entered_bottom")

    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    reticle.set_position(
        camera.unproject_position(global_transform.origin) - reticle.get_size()/2
    )

func _physics_process(_delta : float) -> void:
    # Get the vector from the ship to the cursor
    var direction_to_reticle := _get_vec_to_reticle(projectile_spawn)

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
    if shoot_cooldown - delta > 0:
        shoot_cooldown -= delta
    elif shooting:
        # Get the direction to the reticle
        var direction_to_reticle := _get_vec_to_reticle(projectile_spawn)

        # Spawn a projectile
        var projectile := preload("res://src/Projectile/Projectile.tscn").instance()
        projectile.velocity = direction_to_reticle * 100
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

# Event handlers

func _input(event):
    if event is InputEventMouseMotion:
        reticle.set_position(reticle.get_position() + event.relative*RETICLE_SPEED_MOD)

func _unhandled_input(event):
    if event.is_action_pressed("Shoot"):
        shooting = true
    elif event.is_action_released("Shoot"):
        shooting = false
