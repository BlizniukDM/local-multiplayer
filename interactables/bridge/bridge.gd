extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

var is_visible_bridge = false
var current_activators = 0
var required_activators = 2

func activate(state):
        
    if is_visible_bridge:
        return
    if state:
        current_activators += 1
    else:
        current_activators -= 1
        
    if current_activators >= required_activators:
        is_visible_bridge = true
        set_bridge_properties()


func set_bridge_properties():
    sprite_2d.visible = is_visible_bridge
    collision_shape_2d.set_deferred("disabled", !is_visible_bridge)


func _on_multiplayer_synchronizer_delta_synchronized() -> void:
    set_bridge_properties()
