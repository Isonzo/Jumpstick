extends KinematicBody2D

var speed: int = 800
var dir: Vector2

func _physics_process(delta: float) -> void:
	var collision: KinematicCollision2D = move_and_collide(speed * dir * delta)
	if collision != null:
		var body := collision.collider
		if body.has_method("get_hit"):
			body.get_hit()
		queue_free()
		print("I've hit a %s!" % body.name)

func align() -> void:
	dir = Vector2.RIGHT.rotated(rotation)
