extends Node

signal player_hp_changed(max_hp, old_hp, new_hp)
signal got_carrot

var player : KinematicBody setget set_player, get_player

func set_player(new_player : KinematicBody) -> void:
    player = new_player

func get_player() -> KinematicBody:
    return player

func get_scene_root() -> Node:
    return get_tree().root.get_child(1)
