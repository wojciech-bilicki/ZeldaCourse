extends VBoxContainer

class_name OnScreenEquipmentSlot

@onready var slot_label: Label = $SlotLabel
@onready var texture_rect: TextureRect = %TextureRect
@onready var color_rect: ColorRect = $NinePatchRect/ColorRect


@export var slot_name: String

func _ready() -> void:
	slot_label.text = slot_name

func set_equipment_texture(texture: Texture):
	texture_rect.texture = texture

func on_cooldown(cooldown_timer: float):
	color_rect.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "size", Vector2(40, 40), cooldown_timer)
	tween.tween_callback(on_tween_finished)

func on_tween_finished():
	color_rect.size = Vector2(40, 0)
	color_rect.visible = false
