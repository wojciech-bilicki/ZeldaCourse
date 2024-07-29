extends Node

class_name Inventory

signal spell_activated(spell_index: int)

@onready var inventory_ui: InventoryUI = $"../InventoryUI"
@onready var on_screen_ui: OnScreenUI = $"../OnScreenUI"
@onready var combat_system: CombatSystem = $"../CombatSystem"
@onready var animated_sprite_2d: AnimationController = $"../AnimatedSprite2D"

const PICKUP_ITEM_SCENE = preload("res://Scenes/pickup_item.tscn")
# items currently in inventory
@export var items: Array[InventoryItem] = []

var taken_inventory_slots_count = 0
var selected_spell_index = -1 

func _ready() -> void:
	inventory_ui.equip_item.connect(on_item_equipped)
	inventory_ui.drop_item_on_the_ground.connect(on_item_dropped)
	inventory_ui.spell_slot_clicked.connect(on_spell_slot_clicked)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		inventory_ui.toggle()


func add_item(item: InventoryItem, stacks: int):
	if stacks && item.max_stacks > 1:
		add_stackable_item_to_inventory(item, stacks)
	else:
		var idx = items.find(null)
		if idx != -1:
			items[idx] = item
		else: 
			items.append(item)
		inventory_ui.add_item(item)
		taken_inventory_slots_count += 1
	 
func add_stackable_item_to_inventory(item: InventoryItem, stacks: int):
	#	IS ITEM ALREADY IN INVENTORY	
	# we have to reverse search 
	var item_index = -1
	for i in items.size():
		if items[i] != null and items[i].name == item.name:
			item_index = i
	
	if item_index != -1:
		# add stacks to found item
		
		var inventory_item = items[item_index]
		#		can we add current stack to item in inventory
		if inventory_item.stacks + stacks <= item.max_stacks:
			inventory_item.stacks += stacks 
			items[item_index] = inventory_item
			inventory_ui.update_stack_at_slot_index(inventory_item.stacks, item_index)
		else:
			var stacks_diff = inventory_item.stacks + stacks - item.max_stacks
			var additional_inventory_item = inventory_item.duplicate(true)
			inventory_item.stacks = item.max_stacks
			inventory_ui.update_stack_at_slot_index(inventory_item.max_stacks, item_index)
			additional_inventory_item.stacks = stacks_diff
			items.append(additional_inventory_item)
			inventory_ui.add_item(additional_inventory_item)	
			taken_inventory_slots_count += 1
	else:
		item.stacks = stacks
		items.append(item)
		inventory_ui.add_item(item)	
		taken_inventory_slots_count += 1

func on_item_equipped(idx: int, slot_to_equip: String):
	var item_to_equip = items[idx]
	on_screen_ui.equip_item(item_to_equip, slot_to_equip)
	combat_system.set_active_weapon(item_to_equip.weapon_item, slot_to_equip)
	
	check_magic_ui_visibility()

func on_item_dropped(idx: int):
	clear_inventory_slot(idx)
	eject_item_into_the_ground(idx)
	
	check_magic_ui_visibility()

func clear_inventory_slot(idx: int):
	taken_inventory_slots_count -= 1
	inventory_ui.clear_slot_at_index(idx)
	
func eject_item_into_the_ground(idx: int):
	var inventory_item_to_eject = items[idx]
	var item_to_eject_as_pickup = PICKUP_ITEM_SCENE.instantiate() as PickUpItem
	
	item_to_eject_as_pickup.inventory_item = inventory_item_to_eject
	item_to_eject_as_pickup.stacks = inventory_item_to_eject.stacks
	
	get_tree().root.add_child(item_to_eject_as_pickup)
	
	item_to_eject_as_pickup.disable_collision()
	item_to_eject_as_pickup.global_position = get_parent().global_position
	
	var eject_direction = animated_sprite_2d.item_eject_direction
	
	if eject_direction.x == 0:
		eject_direction.x = randf_range(-1, 1)
	else:
		eject_direction.y = randf_range(-1, 1)
	
	var eject_position = get_parent().global_position + Vector2(20, 20) * eject_direction
	
	var ejection_tween = get_tree().create_tween()
	ejection_tween.set_trans(Tween.TRANS_BOUNCE)
	ejection_tween.tween_property(item_to_eject_as_pickup, "global_position", eject_position, .2)
	ejection_tween.finished.connect(func(): item_to_eject_as_pickup.enable_collision())
	
	if combat_system.right_weapon == inventory_item_to_eject.weapon_item:
		combat_system.right_weapon = null
		on_screen_ui.right_hand_slot.set_equipment_texture(null)
	
	if combat_system.left_weapon == inventory_item_to_eject.weapon_item:
		combat_system.left_weapon = null
		on_screen_ui.left_hand_slot.set_equipment_texture(null)
		
	items[idx] = null
	
func on_spell_slot_clicked(idx: int):
	selected_spell_index = idx
	inventory_ui.set_selected_spell_slot(selected_spell_index)
	spell_activated.emit(selected_spell_index)

func check_magic_ui_visibility():
	var should_show_magic_ui = (combat_system.left_weapon != null and \
	combat_system.left_weapon.attack_type == "Magic") or \
	(combat_system.right_weapon != null and \
	combat_system.right_weapon.attack_type == "Magic")
	inventory_ui.toggle_spells_ui(should_show_magic_ui)
	if should_show_magic_ui == false:
		on_screen_ui.toggle_spell_slot(false, null)
	
	
	
	
	
	
	
	
	
	
