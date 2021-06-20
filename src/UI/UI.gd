extends CanvasLayer

onready var carrot_count := $MarginContainer/HBoxContainer/RichTextLabel
onready var hp_bar := $MarginContainer2/TextureProgress as TextureProgress
onready var hp_bar_tween := hp_bar.get_node("Tween") as Tween

var next_scene_path = "res://src/UI/GameOver.tscn";

var carrots := 0.0

func _ready():
    var _e = Utils.connect("player_hp_changed", self, "_on_player_hp_change")
    _e = Utils.connect("got_carrot", self, "_player_got_carrot")
    carrot_count.set_text("\n" + str(carrots))

func _on_player_hp_change(max_hp : float, _old_hp : float, new_hp : float):
    var player_hp_percent := 100 * new_hp/max_hp
    hp_bar_tween.interpolate_property(
        hp_bar,
        "value",
        hp_bar.value,
        100 * new_hp/max_hp,
        0.25,
        Tween.TRANS_EXPO,
        Tween.EASE_IN_OUT
    )
    hp_bar_tween.start()
    if (new_hp <= 0):
        yield(get_tree().create_timer(3),"timeout")
        get_tree().change_scene(next_scene_path)
    

func _player_got_carrot() -> void:
    carrots += 1
    carrot_count.set_text("\n" + str(carrots))
