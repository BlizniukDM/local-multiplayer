extends Node2D


@onready var pivot: Sprite2D = $Pivot
@onready var icon: Sprite2D = $Pivot/Icon

var rotation_offset = 90.0

func _process(_delta: float) -> void:
    var canvas_transform = get_canvas_transform()
    var top_left = -canvas_transform.origin / canvas_transform.get_scale()
    var size = get_viewport_rect().size / canvas_transform.get_scale()
    var bounds = Rect2(top_left, size)

    update_position_and_rotation(bounds)
    
func update_position_and_rotation(bounds):
#Position
    pivot.global_position.x = clamp(global_position.x, bounds.position.x, bounds.end.x)
    pivot.global_position.y = clamp(global_position.y, bounds.position.y, bounds.end.y)
#Rotation
    pivot.global_rotation = (global_position - pivot.global_position).angle() + deg_to_rad(rotation_offset)
    icon.global_rotation = 0.0
