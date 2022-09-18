extends KinematicBody2D

var speed: int = 800
var dir: Vector2

func _physics_process(delta: float) -> void:
	var collider: KinematicCollision2D = move_and_collide(speed * dir * delta)
	if collider != null:
		print(str(collider.collider_metadata))
		queue_free()

func align() -> void:
	dir = Vector2.RIGHT.rotated(rotation)
