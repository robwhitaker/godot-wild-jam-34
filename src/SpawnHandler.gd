extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Wave0 = preload("res://src/Waves/Wave0.tscn")
var Wave1 = preload("res://src/Waves/Wave1.tscn")
var Waves = [Wave0, Wave1]


# Called when the node enters the scene tree for the first time.
func _ready():
    spawnWave(0)


func spawnWave(waveNum):
    var newWave = Waves[waveNum].instance();
    add_child(newWave)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
