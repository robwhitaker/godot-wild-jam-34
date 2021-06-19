extends KinematicBody

const MAX_LIFETIME := 30.0
const DEFAULT_SPEED := 30.0

var tracking_target : Spatial = null
var speed := DEFAULT_SPEED
var direction := Vector3.ZERO
var lifetime := 0.1

func _physics_process(delta):
    if tracking_target != null:
        direction = global_transform.origin.direction_to(
            tracking_target.global_transform.origin
        )
    var collision = move_and_collide(direction.normalized() * speed * delta)
    if collision != null:
        _handle_collision(collision)



func _process(delta):
    lifetime -= delta
    if lifetime <= 0.0:
        _destroy()

func _on_VisibilityNotifier_camera_entered(_camera : Camera) -> void:
    lifetime = MAX_LIFETIME

func _on_VisibilityNotifier_camera_exited(_camera : Camera) -> void:
    _destroy()

func _handle_collision(collision_dict : KinematicCollision) -> void:
    print(collision_dict)
    _destroy()

func _destroy():
    queue_free()
