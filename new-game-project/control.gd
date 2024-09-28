extends CanvasLayer

@onready var bossG = get_node("/root/BossG")
@onready var playerG = get_node("/root/PlayerG")

@onready var playerStaminaLabel = get_node("stamina")  # This should be a ProgressBar
@onready var playerHealthLabel = get_node("my health")  # This should be a ProgressBar
@onready var bossHealthLabel = get_node("boss health")  # This should be a ProgressBar
@onready var ammoCountLabel = get_node("Ammo count")  # This is a Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_player_health_display()
	update_player_stamina_display()
	update_boss_health_display()
	update_ammo_count_display()  # Initialize ammo count display

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_player_health_display()
	update_player_stamina_display()
	update_boss_health_display()
	update_ammo_count_display()  # Update ammo count display

# Function to create a StyleBoxFlat with the desired color
func create_stylebox(color: Color) -> StyleBoxFlat:
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = color
	return stylebox

# Function to update the player's health display
func update_player_health_display() -> void:
	var player_health_value = playerG.health
	playerHealthLabel.value = player_health_value

# Function to update the player's stamina display
func update_player_stamina_display() -> void:
	var player_stamina_value = playerG.runCurrent
	playerStaminaLabel.value = player_stamina_value

# Function to update the boss's health display
func update_boss_health_display() -> void:
	var boss_health_value = bossG.health
	bossHealthLabel.value = boss_health_value / 100
	
# Function to update the ammo count display
func update_ammo_count_display() -> void:
	var ammo_count_value = playerG.ammo 
	if playerG.ammo <= 0:
		ammo_count_value = 0 # Replace with the actual property for ammo count
	ammoCountLabel.text = str(ammo_count_value)  # Update label text
