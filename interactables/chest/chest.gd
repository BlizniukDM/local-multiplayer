extends Node2D

@export var key_scene: PackedScene

@onready var chest_locked: Sprite2D = $ChestLocked
@onready var chest_unlocked: Sprite2D = $ChestUnlocked
@onready var key_spawn: Node2D = $KeySpawn


var is_locked = true


func _on_ineractable_interacted():
    if is_locked:
        is_locked = false
        var key = key_scene.instantiate()
        key_spawn.add_child(key)
        set_chest_properties()
    

func set_chest_properties():
    chest_locked.visible = is_locked
    chest_unlocked.visible = !is_locked

func _on_chest_synchronizer_delta_synchronized() -> void:
    set_chest_properties()
