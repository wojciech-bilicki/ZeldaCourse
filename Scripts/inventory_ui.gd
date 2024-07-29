extends CanvasLayer

class_name InventoryUI

signal drop_item_on_the_ground(idx: int)
signal equip_item(idx: int, slot_to_equip)
signal spell_slot_clicked(idx: int)

@onready var grid_container: GridContainer = %GridContainer
@onready var spell_slots: Array[InventorySlot] = [
	%FireSpellSlot,
	%IceSpellSlot,
	%PlantSpellSlot
]
@onready var spells_ui: VBoxContainer = %SpellsUI

const INVENTORY_SLOT_SCENE = preload("res://Scenes/UI/inventory_slot.tscn")

@export var size = 8
@export var columns = 4

func _ready():
	grid_container.columns = columns
	
	for i in size:
		var inventory_slot = INVENTORY_SLOT_SCENE.instantiate()
		grid_container.add_child(inventory_slot)
		
		inventory_slot.equip_item.connect(func(slot_to_equip: String): equip_item.emit(i, slot_to_equip))
		inventory_slot.drop_item.connect(func (): drop_item_on_the_ground.emit(i))

	for i in spell_slots.size():
		spell_slots[i].slot_clicked.connect(on_spell_slot_clicked.bind(i))

func toggle():
	visible = !visible


func add_item(item: InventoryItem):
	var slots = grid_container.get_children().filter(func (slot): return slot.is_empty)
	var first_empty_slot = slots.front() as InventorySlot
	first_empty_slot.add_item(item)
	

func update_stack_at_slot_index(stacks_value: int, inventory_slot_index: int):
	if inventory_slot_index == -1:
		return
	var inventory_slot: InventorySlot = grid_container.get_child(inventory_slot_index)
	inventory_slot.stacks_label.text = str(stacks_value)

func clear_slot_at_index(idx: int):
	var empty_inventory_slot: InventorySlot = INVENTORY_SLOT_SCENE.instantiate()
	toggle()
	
	empty_inventory_slot.drop_item.connect(func(): drop_item_on_the_ground.emit(idx))
	empty_inventory_slot.equip_item.connect(func(slot_to_equip: String): equip_item.emit(idx, slot_to_equip))
	
	var child_to_remove = grid_container.get_child(idx)
	grid_container.remove_child(child_to_remove)
	grid_container.add_child(empty_inventory_slot)
	grid_container.move_child(empty_inventory_slot, idx)
	
func on_spell_slot_clicked(i: int):
	spell_slot_clicked.emit(i)

func set_selected_spell_slot(idx: int):
	for i in spell_slots.size():
		spell_slots[i].toggle_button_selected_variation(idx == i)

func toggle_spells_ui(is_visible: bool):
	spells_ui.visible = is_visible
