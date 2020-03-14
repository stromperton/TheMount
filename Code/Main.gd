extends Node

onready var node_world = $World
onready var node_control = $Control

export var package : String
export var lang : String 
export var card : Dictionary

export var health = 3
export var carma = 0

var rng = RandomNumberGenerator.new()

func _ready():
	self.remove_child(node_control)

func pre_checker(card_name):
	print("Загружена карточка '"+card_name+"'")
	get_tree().paused = true
	self.add_child(node_control)

#Вызывается после выбора действия
func post_checker(card_name):
	print("Здоровье: "+ str(health))
	print("Карма: "+ str(carma))
	if card_name == "EXIT":
		get_tree().quit()
	elif health <= 0:
		getka("death.json")
	elif card_name == "END":
		get_tree().paused = false
		self.remove_child(node_control)
	else:
		getka(card_name)

func getka(card_name : String):
	pre_checker(card_name)
	
	var file = File.new()
	var file_path = "res://Cards/"+package+"/"+lang+"/"+ card_name
	
	assert (file.file_exists(file_path))
	file.open(file_path, file.READ)
	card = parse_json(file.get_as_text())
	node_control.get_node("MainText").text = card["text"]
	node_control.get_node("Title").text = card["title"]
	if card.has("health"):
		health += int(card["health"])
	if card.has("carma"):
		carma += int(card["carma"])

	#Choises
	var choise_container = node_control.get_node("ScrollContainer/VBoxContainer")
	for n in choise_container.get_children():
		n.queue_free()
	
	for i in card["choises"]:
		var choise = load("Scenes/Choise.tscn").instance()
		var choise_title = choise.get_child(1)
		choise_title.text = i["title"]
		choise.next_card = i["next"]
		
		choise_container.add_child(choise)
		
	var fictive = Control.new()
	choise_container.add_child(fictive)

func get_random_card():
	rng.randomize()
	if !rng.randf() < 0.01:
		return
	
	var file = File.new()
	var file_path = "res://Cards/"+package+"/"+lang+"/"+ "random/random.json"
	assert (file.file_exists(file_path))
	file.open(file_path, file.READ)
	var rand = parse_json(file.get_as_text())
	
	rng.randomize()
	var prob = rng.randf()
	var total_sum = 0.0
	for card_name in rand:
		total_sum += rand[card_name]
		if prob <= total_sum:
			return "random/"+card_name
			
func general_get_card(tile_name : String):
	var card_name
	if tile_name == "point_default":
		card_name = get_random_card()
	else:
		card_name = tile_name.to_lower()+".json"
	
	if card_name:
		getka(card_name)
	
	return card_name
	
