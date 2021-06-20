extends Spatial

const ACCELERATION := 700.0
const MAX_SPEED := 80.0

var velocity := Vector3(60, 60, 0)
var time_until_full_track := 1.0

func _physics_process(delta) -> void:
    var player_pos : Vector3
    var player := Utils.get_player()
    if player != null && is_instance_valid(player):
        player_pos = player.global_transform.origin
    else:
        return
    var direction_to_player := global_transform.origin.direction_to(player_pos)
    time_until_full_track -= delta
    if time_until_full_track > 0 && global_transform.origin.distance_to(player_pos) > 10.0:
        velocity += ACCELERATION * direction_to_player * delta
        velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
        velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
        velocity.z = clamp(velocity.z, -MAX_SPEED, MAX_SPEED)
    else:
        velocity = direction_to_player * MAX_SPEED
    global_transform.origin += velocity * delta
