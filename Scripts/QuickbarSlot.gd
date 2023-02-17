extends Panel

var default_slot = preload("res://Assets/quickbar_slot.png")

var default_style: StyleBoxTexture = null
var active_style: StyleBoxTexture = null

var ItemClass = preload("res://Scenes/Item.tscn")
export (Texture) var item = null

func _ready():
	default_style = StyleBoxTexture.new()
	default_style.texture = default_slot
	active_style = StyleBoxTexture.new()
	active_style.modulate_color = Color.aqua
	active_style.texture = default_slot
	refresh_style()
	
func refresh_style():
	if item == null:
		set('custom_styles/panel', default_style)
	else:
		set('custom_styles/panel', active_style)

func assign_item(new_item):
	item = new_item
	refresh_style()
#
#func putIntoSlot(new_item):
#	item = new_item
#	item.position = Vector2(0,0)
#	var intentoryNode = find_parent("Inventory")
#	intentoryNode.remove_child(item)
#	add_child(item)
#	refresh_style()
