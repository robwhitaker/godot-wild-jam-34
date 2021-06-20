extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Wave0 = preload("res://src/Waves/Wave0.tscn")
var Wave1 = preload("res://src/Waves/Wave1.tscn")
var Wave2 = preload("res://src/Waves/Wave2.tscn")
var Wave3 = preload("res://src/Waves/Wave3.tscn")
var Waves = [Wave0, Wave1, Wave2, Wave3]
var currentWave = 0
var currentWaveNode
const MAXWAVE = 3

# Called when the node enters the scene tree for the first time.
func _ready():
    spawnWave(currentWave)

func spawnWave(waveNum):
    currentWaveNode = Waves[waveNum].instance();
    currentWaveNode.translation.z += -250;
    add_child(currentWaveNode)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func _on_spawnEntrance_area_exited(_area):
    if (currentWave < MAXWAVE):
        print("Spawning next wave...")
        currentWave += 1;
        spawnWave(currentWave)
    else:
        currentWave = 0;
        spawnWave(currentWave)


func _on_ActivationArea_area_entered(area):
    print("activation area touched")
    if area.is_in_group("Activateable"):
        area.go()
    pass # Replace with function body.
