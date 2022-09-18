extends KinematicBody2D

const GRAVITY: int = 400
const JUMP_POWER: int = 250
const ANGULAR_SPEED: float = PI * 1.75
const KNOCKBACK_STRENGTH: int = -160
const SLIDE_FACTOR: float = 0.1
const SPREAD: float = 0.02
var velocity: Vector2 = Vector2.ZERO
var can_shoot: bool = true
var shot_amount: int = 5
var SCREEN_X = ProjectSettings.get_setting("display/window/size/width")
var SCREEN_Y = ProjectSettings.get_setting("display/window/size/height")

onready var shell: PackedScene = preload("res://assets/particles/shell_particle.tscn")
onready var bullet: PackedScene = preload("res://actors/Bullet.tscn")
onready var shell_eject: Position2D = $Arms/ShellEject
onready var shoot_point: Position2D = $Arms/ShootPoint




func _ready() -> void:
	randomize()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	aim_gun()
	get_input(delta)
	decide_to_jump()
	offset_cam_with_mouse()
	
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, 2 * PI)
	

func decide_to_jump() -> void:
	if is_on_floor():
		var floor_normal: Vector2 = get_floor_normal()
		var player_angle: Vector2 = Vector2.UP.rotated(rotation)
		var angle_to_normal: float = player_angle.angle_to(floor_normal)

		if abs(angle_to_normal) > PI / 3:
			velocity.x = lerp(velocity.x, 0, SLIDE_FACTOR)
		else:
			jump()


func get_input(delta: float) -> void:
	var dir: float = Input.get_axis("left", "right")
	
	rotate(ANGULAR_SPEED * dir * delta)
	
	if Input.is_action_just_pressed("shoot") and can_shoot:
		can_shoot = false
		var knockback: Vector2 = Vector2.UP.rotated(rotation + $Arms.rotation + PI/2).normalized()
		velocity += knockback * KNOCKBACK_STRENGTH
		$ShotDelay.start()
		$ShellEjectTimer.start()
		for i in shot_amount:
			if i == 0:
				spawn_bullet(true)
			else:
				spawn_bullet()


func jump() -> void:
	var jump_vector = Vector2.UP.rotated(rotation).normalized()
	velocity.y = jump_vector.y * JUMP_POWER
	velocity.x = jump_vector.x * JUMP_POWER + velocity.x


func apply_gravity(delta: float) -> void:
	velocity.y += GRAVITY * delta


func aim_gun() -> void:
	if get_local_mouse_position().x < 0:
		$Sprite.flip_h = true
		$Arms.flip_v = true
	else:
		$Sprite.flip_h	= false
		$Arms.flip_v = false
	$Arms.look_at(get_global_mouse_position())

#Spawns a shell at ShellEject position and flips y velocity of particle if $Arms is flipped to ensure it always shoots up relative to the shotgun
func spawn_shell():
	var shell_instance: CPUParticles2D = shell.instance()
	shell_eject.add_child(shell_instance)
	if $Arms.flip_v == true:
		shell_instance.direction.y = shell_instance.direction.y * -1
	shell_instance.emitting = true


func spawn_bullet(first_shot: bool = false):
	var bullet_instance: KinematicBody2D = bullet.instance()
	owner.add_child(bullet_instance)
	bullet_instance.rotation = $Arms.rotation + rotation 
	if not first_shot:
		bullet_instance.rotation += (randf() * 2 -1) * SPREAD
	bullet_instance.position = shoot_point.global_position
	bullet_instance.align()
	

func offset_cam_with_mouse() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	$Camera2D.offset.y = lerp($Camera2D.offset.y, (mouse_pos.y - global_position.y) / (SCREEN_Y / 50) - 20, 0.2)
	$Camera2D.offset.x = lerp($Camera2D.offset.x, (mouse_pos.x - global_position.x) / (SCREEN_X / 50), 0.2)


func _on_ShotDelay_timeout() -> void:
	can_shoot = true


func _on_ShellEjectTimer_timeout() -> void:
	spawn_shell()
