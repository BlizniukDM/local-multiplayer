extends Node

@export var ui : Control
@export var level_scene : PackedScene
@export var level_container : Node
@export var ip_line_edit : LineEdit
@export var status_label : Label
@export var not_connected_hbox : HBoxContainer
@export var host_hbox : HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    multiplayer.connection_failed.connect(_on_connecting_failed)
    multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_host_button_pressed() -> void:
    host_hbox.show()
    not_connected_hbox.hide()
    status_label.text = "Hosting!"
    Lobby.create_game()

func _on_join_button_pressed() -> void:
    not_connected_hbox.hide()
    Lobby.join_game(ip_line_edit.text)
    status_label.text = "Connecting..."

func _on_start_button_pressed() -> void:
    hide_menu.rpc()
    change_level.call_deferred(level_scene)

func change_level(scene):
    for child in level_container.get_children():
        level_container.remove_child(child)
        child.level_complete.disconnect(_on_level_complete)
        child.queue_free()
    var new_level = scene.instantiate()
    level_container.add_child(new_level)
    new_level.level_complete.connect(_on_level_complete)

func _on_connecting_failed():
    status_label.text = "Connecting failed"
    not_connected_hbox.show()
    
func _on_connected_to_server():
    status_label.text = "Connected"

@rpc("call_local", "authority", "unreliable_ordered")
func hide_menu():
    ui.hide()
    
func _on_level_complete():
    #call_deferred("change_level", level_scene)
    change_level.call_deferred(level_scene)
