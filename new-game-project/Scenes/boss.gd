extends CharacterBody2D

@onready var bossG = get_node("/root/BossG")
var isMeleeRange = false
var isLaserRange = false

func _process(delta: float) -> void:
	
	if bossG.health > 3800:
		bossG.phase1()
	elif bossG.health >2000 and bossG.health < 3800:
		bossG.phase2()
	elif bossG.health < 2000:
		bossG.phase3()







func _on_punch_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		isMeleeRange = true




func _on_punch_detection_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		#print(isMeleeRange)
		isMeleeRange = false


func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		#print(isMeleeRange)
		isLaserRange = true


func _on_detection_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		#print(isMeleeRange)
		isLaserRange = false
