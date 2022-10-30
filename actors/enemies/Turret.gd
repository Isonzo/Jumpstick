extends StaticBody2D

const LERP_SPEED : float= 0.05
const SPREAD: float = 0.02

var previous_angle: float = 0

export (PackedScene) onready var bullet

onready var barrel: Sprite = $Base/Barrel
onready var shoot_point: Position2D = $Base/Barrel/ShootPoint
onready var raycast: RayCast2D = $Base/Barrel/Sightline
var player: KinematicBody2D


func _ready() -> void:
	player = Globals.player


func _physics_process(delta) -> void:
	take_aim()
	if (seeing_player()) and $ReloadTimer.time_left == 0:
		$ReloadTimer.start()


func take_aim() -> void:
	if player != null:
		var current_angle = lerp_angle(barrel.rotation, (player.global_position - global_position).normalized().angle(), LERP_SPEED)
		
		barrel.rotation = current_angle
		
		previous_angle = current_angle

func shoot() -> void:
	var bullet_instance: KinematicBody2D = bullet.instance()
	owner.add_child(bullet_instance)
	bullet_instance.rotation = barrel.rotation + rotation 
	bullet_instance.rotation += (randf() * 2 -1) * SPREAD
	bullet_instance.align()
	bullet_instance.global_position = shoot_point.global_position
	

func seeing_player() -> bool:
	var collider = raycast.get_collider()
	if collider == null:
		return false
	return collider.name == "Player"


func _on_ReloadTimer_timeout() -> void:
	shoot()
