extends Control

onready var node_main = get_node("/root/Main")
var next_card : String

func _on_TextureButton_pressed():
	print(get_child(1).text)
	node_main.post_checker(next_card)
