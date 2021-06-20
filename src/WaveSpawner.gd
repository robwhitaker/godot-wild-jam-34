extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var VELOCITY = 20;

# Called when the node enters the scene tree for the first time.
func _ready():
    pass


func _physics_process(delta):
    translation.z += VELOCITY*delta;
    print(translation.z)
    if (translation.z > 0):
        print("About to free wave...")
        queue_free();
