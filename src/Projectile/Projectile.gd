extends Spatial

const MAX_LIFETIME = 30.0

var velocity := Vector3.ZERO
var lifetime := 0.1

func _physics_process(delta):
    var old_pos := global_transform.origin
    global_translate(velocity * delta)
    var new_pos := global_transform.origin

    var space_state := get_world().direct_space_state

    var collision := space_state.intersect_ray(old_pos, new_pos)

    if collision != {}:
        _handle_collision(collision)

func _process(delta):
    lifetime -= delta
    if lifetime <= 0.0:
        _destroy()

func _on_VisibilityNotifier_camera_entered(_camera : Camera) -> void:
    lifetime = MAX_LIFETIME

func _on_VisibilityNotifier_camera_exited(_camera : Camera) -> void:
    _destroy()

func _handle_collision(collision_dict : Dictionary) -> void:
    pass

func _destroy():
    queue_free()
