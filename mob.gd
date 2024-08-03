extends RigidBody2D

var initial_linear_velocity = Vector2()
var initial_angular_velocity = 0.0


func _self_unfreeze():
	freeze = false
	sleeping = false
	linear_velocity = initial_linear_velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("mobs")
	$AnimatedSprite2D.play()
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
