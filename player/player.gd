extends CharacterBody2D


@export var player_camera: PackedScene
@export var movement_speed = 300.0
@export var gravity = 30.0
@export var jump_strength = 600.0
@export var player_sprite :AnimatedSprite2D
@export var max_jumps = 1
@export var push_force = 10


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var initial_sprite_scale = player_sprite.scale
@onready var player_finder: Node2D = $PlayerFinder


var target_position :Vector2 = Vector2.INF
var owner_id = 1
var jump_count = 0
var camera_instance
var state = PlayerState.IDLE
var current_interactable


enum PlayerState {
    IDLE,
    WALKING,
    JUMPING,
    READY_TO_JUMP,
    FALLING,
    DOUBLE_JUMPING
}

func _enter_tree() -> void:
    owner_id = name.to_int()
    set_multiplayer_authority(owner_id)
    if owner_id != multiplayer.get_unique_id():
        return
        
    add_camera()

func _process(delta: float) -> void:
    if multiplayer.multiplayer_peer == null:
        return
        
    if owner_id != multiplayer.get_unique_id():
        global_position = HelperFunctions.ClientInterpolate(global_position, target_position, delta)
        return
    
    camera_position()
    

func _physics_process(_delta: float) -> void:
    if owner_id != multiplayer.get_unique_id():
        return
    
    var horizontal_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    velocity.x = horizontal_input * movement_speed
    velocity.y += gravity
    
    if Input.is_action_just_pressed("interact"):
        if current_interactable != null:
            current_interactable.interact.rpc_id(1)
    
    player_animation()
    move_and_slide()
    
    target_position = global_position
    
    for i in get_slide_collision_count():
        var collider = get_slide_collision(i)
        var pushable = collider.get_collider() as PushableObject
        if pushable == null:
            continue
        var point = collider.get_position() - pushable.global_position
        pushable.push(-collider.get_normal() * push_force, point)
    
    player_direction(horizontal_input)

func _on_animated_sprite_2d_animation_finished() -> void:
    if state == PlayerState.JUMPING:
        player_sprite.play("jump")

func add_camera():
    camera_instance = player_camera.instantiate()
    camera_instance.global_position.y = 425
    get_parent().add_child.call_deferred(camera_instance)


func camera_position():
    camera_instance.global_position.x = player_sprite.global_position.x
    camera_instance.global_position.y = player_sprite.global_position.y
    if camera_instance.global_position.y > 425:
        camera_instance.global_position.y = 425


func player_direction(horizontal_input):
     if not is_zero_approx(horizontal_input):#x != 0
        if horizontal_input < 0:
            player_sprite.scale = Vector2(-initial_sprite_scale.x, initial_sprite_scale.y)
        else:
            player_sprite.scale = initial_sprite_scale


func player_animation():
    #Decide State
    if velocity.x == 0 and is_on_floor(): #######
        state = PlayerState.IDLE
    elif velocity.x != 0 and is_on_floor():
        state = PlayerState.WALKING
    else:
        state = PlayerState.JUMPING
    if Input.is_action_just_pressed("jump") and is_on_floor(): #######
        state = PlayerState.READY_TO_JUMP
        
    if velocity.y > 0.0 and not is_on_floor():
        if Input.is_action_just_pressed("jump"):
            state = PlayerState.DOUBLE_JUMPING
        else:
            state = PlayerState.FALLING
     
    #Process State        
    match state:
        PlayerState.IDLE:
            player_sprite.play("idle")
            jump_count = 0
            
        PlayerState.WALKING:
            player_sprite.play("walk")
            jump_count = 0
            
        PlayerState.READY_TO_JUMP:
            player_sprite.play("jump_start")
            jump_count += 1
            velocity.y = -jump_strength
            
        PlayerState.DOUBLE_JUMPING:
            player_sprite.play("double_jump_start")
            jump_count += 1
            if jump_count <= max_jumps:
                velocity.y = -jump_strength
                
        PlayerState.JUMPING:
            pass
            
        PlayerState.FALLING:
            player_sprite.play("fall")

    #jump cancelling
    if Input.is_action_just_released("jump") and velocity.y < 0.0:
        velocity.y = 0.0


func _on_interactable_handler_area_entered(area: Area2D) -> void:
    current_interactable = area

func _on_interactable_handler_area_exited(area: Area2D) -> void:
    if current_interactable == area:
        current_interactable = null

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
    player_finder.visible = false

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
    player_finder.visible = true
