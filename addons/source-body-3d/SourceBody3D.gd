class_name SourceBody3D extends CharacterBody3D

@export var max_ground_speed := 5.5
@export var max_ground_accel := max_ground_speed * 8.0
@export var max_air_speed := 0.7
@export var max_air_accel := 200.0
@export var max_slope := 1.0
@export var jump_force := 4.0
@export var gravity := 12.0
@export var grounded_height := 0.01
@export var friction := 2

func grounded() -> bool:
	return test_move(global_transform, Vector3(0, -grounded_height, 0))

func s_move_and_slide(delta: float, wasd_input: Vector2, is_jumping: bool) -> void:
	var wish_dir := wasd_input
	wish_dir = wish_dir.rotated(-rotation.y)
	
	var vel_planar := Vector2(velocity.x, velocity.z)
	var vel_vertical := _apply_gravity(delta, velocity.y)
	vel_planar = _apply_friction(delta, vel_planar, wish_dir, is_jumping)
	vel_planar = _update_velocity(delta, vel_planar, wish_dir)
	vel_vertical = _check_for_jump(vel_vertical,is_jumping)
	
	velocity = Vector3(vel_planar.x, vel_vertical, vel_planar.y)
	
	move_and_slide()

func _apply_gravity(delta: float, vel_y: float) -> float:
	if grounded(): return vel_y
	return vel_y - gravity * delta
	
func _apply_friction(delta: float, vel_planar: Vector2, wish_dir: Vector2, is_jumping: bool) -> Vector2:
	if not grounded() or is_jumping: return vel_planar
	
	var v := vel_planar - vel_planar.normalized() * delta * max_ground_accel / friction
	
	if v.length_squared() < 1.0 and wish_dir.length_squared() < 0.01:
		return Vector2.ZERO
	else:
		return v

func _update_velocity(delta: float, vel_planar: Vector2, wish_dir: Vector2) -> Vector2:
	var current_speed := vel_planar.dot(wish_dir)
	var max_speed := max_ground_speed if grounded() else max_air_speed
	var max_accel := max_ground_accel if grounded() else max_air_accel
	var add_speed: float = clamp(max_speed - current_speed, 0.0, max_accel * delta)
	return vel_planar + wish_dir * add_speed
	
func _check_for_jump(y_vel: float, is_jumping: bool) -> float:
	if is_jumping and grounded():
		return jump_force
	
	return y_vel
