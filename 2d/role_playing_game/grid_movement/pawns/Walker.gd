extends Pawn

@onready var parent = get_parent()
#warning-ignore:unused_class_variable
@export var combat_actor: PackedScene
#warning-ignore:unused_class_variable
var lost = false
var tween

func _ready():
	update_look_direction(Vector2.RIGHT)


func _process(_delta):
	var input_direction = get_input_direction()
	if not input_direction:
		return
	update_look_direction(input_direction)

	var target_position = parent.request_move(self, input_direction)
	if target_position:
		move_to(target_position)
		
	else:
		bump()


func get_input_direction():
	return Vector2(
		Input.get_axis(&"ui_left", &"ui_right"),
		Input.get_axis(&"ui_up", &"ui_down")
	)


func update_look_direction(direction):
	var angle = atan2(direction.y, direction.x)
	var pos = Vector2(transform.get_origin())
	transform = Transform2D(angle, pos)


func move_to(target_position):
	tween = get_tree().create_tween()
	target_position = Vector2(target_position.x, target_position.y)
	set_process(false)
	$AnimationPlayer.play("walk")
	var move_direction = (position - target_position).normalized()
#   TODO: Fix tween (seems to be moving backwards then forewards?)
	tween.tween_property($Pivot/Sprite2D, 
		"position", 
		move_direction * 32,
		$AnimationPlayer.current_animation_length)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	$Pivot/Sprite2D.position = position - target_position
	position = target_position

	await $AnimationPlayer.animation_finished

	set_process(true)


func bump():
	$AnimationPlayer.play("bump")
