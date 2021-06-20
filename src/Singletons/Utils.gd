extends Node

func get_scene_root() -> Node:
    return get_tree().root.get_child(1)
