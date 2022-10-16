extends StaticBody2D

const LERP_SPEED : float= 0.05
const MAX_SPEED: float = 0.02

var previous_angle: float = 0

export (PackedScene) var bullet

onready var barrel: Sprite = $Base/Barrel
var player: KinematicBody2D


func _ready():
	player = Globals.player


func _physics_process(delta):
	take_aim()


func take_aim():
	if player != null:
		var current_angle = lerp_angle(barrel.rotation, (player.global_position - global_position).normalized().angle(), LERP_SPEED)
		
		$Label.text = "difference %f" % (current_angle - previous_angle)
		
		if abs(current_angle) - abs(previous_angle) < MAX_SPEED:
			pass
		elif current_angle > previous_angle:
			current_angle = previous_angle + MAX_SPEED
		elif current_angle < previous_angle:
			current_angle = previous_angle - MAX_SPEED
		
		
		
		barrel.rotation = current_angle
		
		previous_angle = current_angle
		
