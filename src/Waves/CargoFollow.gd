extends PathFollow


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var VELOCITY = 20;
export var active = false;

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.
func _physics_process(delta): 
    if (active):
        offset += VELOCITY * delta;
    else:
        offset = 0;

func setActive():
    active = true;
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func _on_Area_go():
    print("ship should go now")
    setActive()
