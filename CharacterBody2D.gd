extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var second_jump = 0

func _ready():
	$AnimatedSprite2D.play("idle")
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():

		velocity.y = JUMP_VELOCITY
		second_jump = 1
	if Input.is_action_just_pressed("ui_accept") and second_jump ==1:
		print("jump",second_jump)
		velocity.y = JUMP_VELOCITY 
		second_jump = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction:
		$AnimatedSprite2D.play("run")
		if direction == -1:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
			
		velocity.x = direction * SPEED
	else:
		$AnimatedSprite2D.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
