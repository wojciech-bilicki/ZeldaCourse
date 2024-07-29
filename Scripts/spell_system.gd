extends Node

class_name SpellSystem

var spell_configs: Array[SpellConfig] = [
	preload("res://Resources/Spells/Fireball/fire_spell_config.tres"),
	preload("res://Resources/Spells/Ice/ice_spell_config.tres"),
	preload("res://Resources/Spells/Plant/plant_spell_config.tres")
]

@onready var animated_sprite_2d: AnimationController = $"../AnimatedSprite2D"
@onready var inventory: Inventory = $"../Inventory"
@onready var on_screen_ui: OnScreenUI = $"../OnScreenUI"
@onready var combat_system: CombatSystem = $"../CombatSystem"

const SPELL_SCENE = preload("res://Scenes/spell.tscn")

var current_spell_cooldown = null
var cooldown_timer = 1000
var active_spell_index = -1

func _ready() -> void:
	inventory.spell_activated.connect(on_spell_activated)
	combat_system.cast_active_spell.connect(on_cast_active_spell)

func _process(delta: float) -> void:
	if current_spell_cooldown != null && cooldown_timer < current_spell_cooldown:
		cooldown_timer += delta

func on_cast_active_spell():
	var spell_direction = animated_sprite_2d.attack_vector
	var spell_config = spell_configs[active_spell_index]
	
	
	
	if cooldown_timer != 0 and cooldown_timer < current_spell_cooldown:
		return
	else: 
		cooldown_timer = 0
	
	on_screen_ui.spell_cooldown_activated(current_spell_cooldown)
	
	var spell_rotation = get_spell_rotation(spell_direction, spell_config.initial_rotation)
	var spell: Spell = SPELL_SCENE.instantiate()
	
	get_tree().root.add_child(spell)
	spell.rotation_degrees = spell_rotation
	spell.direction = spell_direction
	spell.init(spell_config)
	spell.position = get_parent().global_position
	

func get_spell_rotation(spell_direction: Vector2, initial_rotation: int):
	match spell_direction:
		Vector2.LEFT:
			return -180 + initial_rotation
		Vector2.RIGHT:
			return 0 + initial_rotation
		Vector2.UP:
			return -90 + initial_rotation
		Vector2.DOWN:
			return 90 + initial_rotation








func on_spell_activated(idx: int):
	active_spell_index = idx
	var spell_config = spell_configs[idx]
	on_screen_ui.toggle_spell_slot(true, spell_config.ui_texture)
	current_spell_cooldown = spell_config.initial_cooldown
