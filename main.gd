extends Node

@export var mob_scene: PackedScene
@export var mob_destroyer_scene: PackedScene
@export var mob_freezer_scene: PackedScene

var score
var timers = []


func _ready():
	timers.append($ScoreTimer)
	timers.append($MobTimer)
	timers.append($MobDestroyerTimer)
	timers.append($MobFreezerTimer)


func stop_timers():
	for timer in timers:
		timer.stop()
		
		
func start_timers():
	for timer in timers:
		timer.start()


func game_over():
	stop_timers()
	
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()


func new_game():
	$Music.play()
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("mob_destroyers", "queue_free")
	get_tree().call_group("mob_freezers", "queue_afree")
	$HUD.show_message("Get Ready")


# Timers
func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	mob.initial_linear_velocity = mob.linear_velocity

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_start_timer_timeout():
	start_timers()


func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)


# Spawn help packages
func _on_mob_destroyer_timer_timeout():
	var mob_destroyer = mob_destroyer_scene.instantiate()
	var mob_destroyer_spawn_location = $MobDestroyerPath/MobDestroyerSpawnLocation
	
	mob_destroyer_spawn_location.progress_ratio = randf()
	mob_destroyer.position = mob_destroyer_spawn_location.position
	add_child(mob_destroyer)
	
	
func _on_mob_freezer_timer_timeout():
	var mob_freezer = mob_freezer_scene.instantiate()
	var mob_freezer_spawn_location = $MobFreezerPath/MobFreezerSpawnLocation
	
	mob_freezer_spawn_location.progress_ratio = randf()
	mob_freezer.position = mob_freezer_spawn_location.position
	add_child(mob_freezer)


# Handle a package being collected
func _on_player_collected_mob_destroyer(body_id):
	var collected_destroyer_body = instance_from_id(body_id)
	collected_destroyer_body.queue_free()
	get_tree().call_group("mobs", "queue_free")
	

func _on_player_collected_mob_freezer(body_id):
	var collected_freezer_body = instance_from_id(body_id)
	collected_freezer_body.queue_free()
	
	var mobs = get_tree().get_nodes_in_group("mobs")
	for mob in mobs:
		mob.set_deferred("freeze", true)

	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1
	timer.one_shot = true
	timer.timeout.connect(_on_timer_unfreeze_mobs.bind(mobs))
	timer.start()


func _on_timer_unfreeze_mobs(mobs):
	for mob in mobs:
		if mob and is_instance_valid(mob):
			mob.call_deferred("self_unfreeze")
