extends KinematicBody

const MAX_LIFETIME := 30.0
const DEFAULT_SPEED := 30.0

var tracking_target : Spatial = null
var speed := DEFAULT_SPEED
var direction := Vector3.ZERO
var lifetime := 0.1

func _physics_process(delta : float) -> void:
    if tracking_target != null && is_instance_valid(tracking_target):
        direction = global_transform.origin.direction_to(
            tracking_target.global_transform.origin
        )
    var collision = move_and_collide(direction.normalized() * speed * delta)
    if collision != null:
        _handle_collision(collision.collider)

func _process(delta : float) -> void:
    lifetime -= delta
    if lifetime <= 0.0:
        _destroy()

func _on_VisibilityNotifier_camera_entered(_camera : Camera) -> void:
    lifetime = MAX_LIFETIME

func _on_VisibilityNotifier_camera_exited(_camera : Camera) -> void:
    _destroy()

func _handle_collision(collider : Spatial) -> void:
    if is_instance_valid(collider) && collider.has_method("apply_damage"):
        collider.apply_damage(1)
    _explode()

func _explode() -> void:
    var root : Spatial = Utils.get_scene_root() as Spatial
    var explosion : Particles = preload("res://src/Explosion/SmallExplosion.tscn").instance()
    explosion.global_transform = global_transform
    explosion.emitting = true
    root.add_child(explosion)
    _destroy()

func _destroy() -> void:
    queue_free()

func _on_Area_area_entered(area : Area) -> void:
    _handle_collision(area.get_parent())
