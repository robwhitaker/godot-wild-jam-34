extends KinematicBody

const MAX_SPEED := 20.0
const ROTATION_DEGREES := 60.0

const RETICLE_SPEED_MOD := 0.35

var velocity := Vector3.ZERO

var move_left_mod := 1.0
var move_right_mod := 1.0
var move_top_mod := 1.0
var move_bottom_mod := 1.0

onready var vis_notif_left := $VisibilityNotifiers/Left as VisibilityNotifier
onready var vis_notif_right := $VisibilityNotifiers/Right as VisibilityNotifier
onready var vis_notif_top := $VisibilityNotifiers/Top as VisibilityNotifier
onready var vis_notif_bottom := $VisibilityNotifiers/Bottom as VisibilityNotifier

onready var reticle := $Reticle as TextureRect

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

    var ship_pos := camera.unproject_position(global_transform.origin)
    reticle.set_position(Vector2(
        ship_pos.x - reticle.get_size().x/2,
        ship_pos.y - reticle.get_size().y/2)
    )

func _physics_process(_delta : float) -> void:
    # Get the vector from the ship to the cursor
    var ship_pos := _to_vec3(
        camera.unproject_position(global_transform.origin),
        global_transform.origin.z
    )
    var reticle_pos := Vector3(
        reticle.get_position().x + reticle.get_size().x/2,
        reticle.get_position().y + reticle.get_size().y/2,
        -500
    )
    var direction_to_reticle := ship_pos.direction_to(reticle_pos)
    direction_to_reticle.y *= -1

    # Point the ship toward the cursor
    set_rotation_degrees(Vector3(
        direction_to_reticle.y * ROTATION_DEGREES,
        direction_to_reticle.x * -ROTATION_DEGREES,
        0
    ))

    # Apply velocity toward the cursor
    velocity = direction_to_reticle * MAX_SPEED
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

    # If we are at the cursor, stop moving
    if direction_to_reticle == Vector3.ZERO:
        velocity = Vector3.ZERO

    # Actually move
    velocity = move_and_slide(velocity)

# Helpers

func _to_vec3(vec2 : Vector2, z : float) -> Vector3:
    return Vector3(vec2.x, vec2.y, z)


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
        var reticle_pos := reticle.get_position()
        var new_pos : Vector2 = reticle_pos + event.relative * RETICLE_SPEED_MOD
        reticle.set_position(new_pos)
