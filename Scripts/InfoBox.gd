extends Control

func _ready():
	InfoEventManager.connect("show_infobox", self, "_on_show_Infobox")

func _on_show_Infobox(info):
	get_parent().remove_child(self)
	info.target.get_node("InfoAnchor").add_child(self)
	get_node("Panel/Name").text = info.name as String
	get_node("Panel/Image").frames = info.image
	get_node("Panel/Level").text = "Level " + info.level as String
	get_node("Panel/HP").text = "HP: " + info.hp as String
