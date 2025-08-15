extends Node

@onready var source_body: SourceBody3D = $".."
@onready var camera: Camera3D = $"../Eye/Camera"
@onready var eye: Node3D = $"../Eye"

@export var sens := 0.0004
var _mouse_input: Vector2
var _future_rotation: Vector2

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("left", "right", "forward", "back")
	var is_jumping := Input.is_action_pressed("jump")
	source_body.s_move_and_slide(delta, input, is_jumping)

func _process(delta: float) -> void:
	camera.global_transform = eye.get_global_transform_interpolated()

	_future_rotation.x = clampf(_future_rotation.x + _mouse_input.y, deg_to_rad(-90), deg_to_rad(85))
	_future_rotation.y += _mouse_input.x
	
	eye.transform.basis = Basis.from_euler(Vector3(_future_rotation.x, 0.0, 0.0))
	source_body.global_transform.basis = Basis.from_euler(Vector3(0.0, _future_rotation.y, 0.0))
	
	_mouse_input = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_input.x += -event.screen_relative.x * sens
		_mouse_input.y += -event.screen_relative.y * sens
