extends RigidBody2D


var speed = 225.0
var direction : Vector2

var rng = RandomNumberGenerator.new()
@onready var health : PackedScene = preload("res://Scenes/health.tscn")
@onready var playerG = get_node("/root/PlayerG")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("Effects")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("wall"):
		call_deferred("queue_free")  # Defer freeing the projectile
		if rng.randi_range(0, 10) > 5:
			print("spawned")
			var health_instance = health.instantiate()
			health_instance.global_position = area.global_position
			get_tree().root.call_deferred("add_child", health_instance)  # Safely add the health instance later
		area.get_parent().call_deferred("queue_free")  # Safely remove the wall's parent node

	if area.is_in_group("player"):
		playerG.hurt()
		call_deferred("queue_free")  # Safely remove the projectile when colliding with the player
