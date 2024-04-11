extends Node2D

signal level_complete

@export var players_container : Node2D
@export var player_scenes : Array[PackedScene] 
@export var spawns : Array[Node2D]
@export var door_key: DoorKey

@onready var player_spawner: MultiplayerSpawner = $"----- Players -----/PlayerSpawner"
#@onready var door_keys: DoorKey = $"."

var spawn_index = 0
var next_character_index = 0

func _ready() -> void:
    player_spawner.spawn_function = add_player
    
    if not multiplayer.is_server():
        return

    multiplayer.peer_disconnected.connect(delete_player)
    
    for id in multiplayer.get_peers():
        player_spawner.spawn([id, spawn_player()])

    player_spawner.spawn([1, spawn_player()])
    
    door_key.all_players_finished.connect(_on_all_players_finished, CONNECT_ONE_SHOT)
    
func _exit_tree() -> void:
    if multiplayer.multiplayer_peer == null:
        return
        
    if not multiplayer.is_server():
        return
        
    multiplayer.peer_disconnected.disconnect(delete_player)   


    
func add_player(data :Array):
    var player_instance = player_scenes[next_character_index].instantiate()
    next_character_index += 1
    if next_character_index >= len(player_scenes):
        next_character_index = 0
    player_instance.position = data[1]
    player_instance.name = str(data[0])
    return player_instance

func delete_player(id):
    if not players_container.has_node(str(id)):
        return
        
    players_container.get_node(str(id)).queue_free()

func spawn_player():
    var spawn = spawns[spawn_index].position
    spawn_index += 1
    if spawn_index >= len(spawns):
        spawn_index = 0
    return spawn

func _on_all_players_finished():
    #door_key.all_players_finished.disconnect(_on_all_players_finished)
    level_complete.emit()

