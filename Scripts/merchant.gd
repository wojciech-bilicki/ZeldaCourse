extends Sprite2D

class_name Merchant

@export var items_to_buy: Array[InventoryItem]

@onready var label: Label = $Label
@onready var shopping_ui = $ShoppingUI as ShoppingUI

var can_trigger_merchant_ui = false

func _ready() -> void:
	shopping_ui.items_to_buy = items_to_buy
	shopping_ui.setup_buying_grid()



func _on_area_2d_body_entered(body: Node2D) -> void:
	can_trigger_merchant_ui = true
	label.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	can_trigger_merchant_ui = false
	label.visible = false
	shopping_ui.visible = false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("merchant") and can_trigger_merchant_ui:
		shopping_ui.visible = true
		var player = get_tree().get_first_node_in_group("player") as Player
		shopping_ui.items_to_sell = (player.find_child("Inventory") as Inventory).items
		shopping_ui.setup_selling_grid()
	
	if Input.is_action_just_pressed("ui_cancel") && shopping_ui.visible:
		shopping_ui.visible = false
		
		 
