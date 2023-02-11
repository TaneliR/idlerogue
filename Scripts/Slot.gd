extends Panel

var empty_slot = preload("res://Assets/invslot_empty.png")
var filled_slot = preload("res://Assets/invslot_filled.png")

var default_style: StyleBoxTexture = null
var empty_style: StyleBoxTexture = null

var ItemClass = preload("res://Scenes/Item.tscn")
var item = null

func _ready():
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	default_style.texture = filled_slot
	empty_style.texture = empty_slot
	
	if randi() % 2 == 0:
		item = ItemClass.instance()
		add_child(item)
	refresh_style()
	
func refresh_style():
	if item == null:
		set('custom_styles/panel', empty_style)
	else:
		set('custom_styles/panel', default_style)

func pickFromSlot():
	remove_child(item)
	var inventoryNode = find_parent("Inventory")
	inventoryNode.add_child(item)
	item = null
	refresh_style()
	
func putIntoSlot(new_item):
	item = new_item
	item.position = Vector2(0,0)
	var intentoryNode = find_parent("Inventory")
	intentoryNode.remove_child(item)
	add_child(item)
	refresh_style()
