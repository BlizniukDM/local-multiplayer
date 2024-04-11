extends Node2D

class_name DoorKey

signal all_players_finished

@onready var door_closed: Sprite2D = $DoorClosed
@onready var door_open: Sprite2D = $DoorOpen
@onready var exit_area: Area2D = $ExitArea


var is_open = false
var finished_players = 0


func set_door_key_properties():
    door_open.visible = is_open
    door_closed.visible = !is_open

func _on_multiplayer_synchronizer_delta_synchronized() -> void:
    set_door_key_properties()

func _on_area_2d_area_entered(area: Area2D) -> void:
    if not multiplayer.is_server():
        return
    if is_open:
        return
        
    is_open = true    
    exit_area.monitoring = true
    area.get_owner().queue_free()
    set_door_key_properties()
    


func _on_exit_area_body_entered(body: Node2D) -> void:
    body.queue_free()
    finished_players += 1
    if finished_players > len(multiplayer.get_peers()):
        all_players_finished.emit()
    
