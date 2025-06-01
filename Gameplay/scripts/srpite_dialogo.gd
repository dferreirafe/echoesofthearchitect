extends TextureRect

@export var Name : String
@export var color : Color

@onready var character_label: RichTextLabel = $"../Balloon/Panel/CharacterLabel"

func _physics_process(delta: float) -> void:
	
	if $"../Balloon/Panel/CharacterLabel".text == Name:
		%CharacterLabel.modulate = %CharacterLabel.modulate.lerp(color, 15 * delta)
		modulate = modulate.lerp(Color(1,1,1), 15 * delta)
		print("el ", Name, " esta hablando")
	else:
		modulate = modulate.lerp(Color(0.169, 0.169, 0.169), 15 * delta)
