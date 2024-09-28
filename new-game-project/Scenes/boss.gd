extends CharacterBody2D

@onready var bossG = get_node("/root/BossG")
var isMeleeRange = false

func _process(delta: float) -> void:
	bossG.phase1()








func _on_punch_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print(isMeleeRange)
		isMeleeRange = true



func _on_detection_area_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
