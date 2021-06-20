extends PathFollow

const VELOCITY = 50;
export var randomOffset = 0;


# Called when the node enters the scene tree for the first time.
func _ready():
    randomOffset = rand_range(0,100)
    offset = randomOffset

func _physics_process(delta): 
    offset += VELOCITY * delta;

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
