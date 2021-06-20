extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal go

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func go():
    emit_signal("go")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
