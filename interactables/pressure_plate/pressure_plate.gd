extends Node2D

signal toggle(state)

@onready var plate_up: Sprite2D = $PlateUp
@onready var plate_down: Sprite2D = $PlateDown

var bodies_on_plates = 0
var is_down = false

func _on_area_2d_body_entered(_body: Node2D) -> void:
    if not multiplayer.is_server():
        return
    bodies_on_plates += 1
    if bodies_on_plates > 1:
        return
    update_plate_state()
    print(str(bodies_on_plates))

func _on_area_2d_body_exited(_body: Node2D) -> void:
    if not multiplayer.is_server():
        return
    if bodies_on_plates > 1:
        return
    bodies_on_plates -= 1
    update_plate_state()

func update_plate_state():
    is_down = bodies_on_plates >= 1 #true
    toggle.emit(is_down)
    set_plate_properties()
    #if bodies_on_plates <= 0:
        #is_down = false
    #else:
        #is_down = true 

func set_plate_properties():
    plate_down.visible = is_down
    plate_up.visible = !is_down


func _on_plate_synchronizer_delta_synchronized() -> void:
    set_plate_properties()
