extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var next_scene_path = "res://src/TestStuff/PathTest.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    pass # Replace with function body.

func _unhandled_input(event):
    if event.is_action_released("ui_accept"):
        get_tree().change_scene(next_scene_path)
    elif event.is_action_pressed("ui_cancel"):
        get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
