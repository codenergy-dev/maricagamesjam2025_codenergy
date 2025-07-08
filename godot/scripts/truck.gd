class_name Truck
extends Node2D

var has_cargo = ["truck", "truck_firefighter", "truck_firefighter_2"]
var has_gas = ["truck_gas"]
var has_tractor = ["truck_tow"]

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var truck: RigidBody2D = $RigidBody2D
@onready var cab: StaticBody2D = $Cab
@onready var cargo: StaticBody2D = $Cargo
@onready var gas: StaticBody2D = $Gas
@onready var tractor: StaticBody2D = $Tractor
@onready var visible_on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	var animations = animated_sprite.sprite_frames.get_animation_names()
	if animations.is_empty():
		return
	
	var random_index = randi() % animations.size()
	var random_truck = animations[random_index]
	
	animated_sprite.play(random_truck)
	
	if not has_cargo.has(random_truck):
		cargo.queue_free()
	if not has_gas.has(random_truck):
		gas.queue_free()
	if not has_tractor.has(random_truck):
		tractor.queue_free()

func _physics_process(delta: float) -> void:
	if visible_on_screen.is_on_screen():
		truck.global_position.x = global_position.x - 80 * delta
	global_position = truck.global_position
