extends Node

var inventory = {}
var weapons = {}

onready var slot_scene = preload("res://slot_0.tscn")
var is_dragging = false
var dragged_item = null
var rmb_pressed = false

var dragged_from_window = null
	
	
	#IMPORTANT !!!
	#I used the following scene tree:
	
	#	Node		(holding this script)
	#		TextureRect		(called "inventory")
	#			ScrollContainer
	#				GridContainer
	#		TextureRect		(called "weapons")
	#			ScrollContainer
	#				GridContainer
	#		TextureRect		(called "drag_item", hidden - visibility changed from the editor)
	#		WindowDialog		(hidden - visibility changed from the editor)
	#			Label
	
	
func _ready():
	set_process(false)
	
	#Creating inventory as dictionary to store info like item ID or amount of that item on that slot
	for slot in range (0, 40):	#which means 40 inventory slots
		inventory[String(slot)] = {"id": "0"} 	#You can continue adding new keys with values here in the same style,
												#so it can actually look like this: {"id": "0", "amount": 0}
	for weapon in range (0, 2):
		weapons[String(weapon)] = {"id": "0"}	#Weapons are not equiped by player yet, so don't add anything

	#Now add some items to the inventory
	inventory["5"]["id"] = "1"
	inventory["12"]["id"] = "2"
	inventory["3"]["id"] = "3"
	
	var inventories = ["inventory", "weapons"]		# Variables (var) are called the same way as main nodes,
													# which means it is easier to access for use in the functions
	for window in inventories:
		load_inv(window)
	
func load_inv(window):
	if get_node(String(window) + "/ScrollContainer/GridContainer").get_child_count() > 0:
		for item in get_node(String(window) + "/ScrollContainer/GridContainer").get_children():
			item.set_name(item.name + "_terminating")
			
			# These checks are avoiding possible glitches and error messages
			if item.is_connected("slot_pressed", self, "slot_pressed"):
				item.disconnect("slot_pressed", self, "slot_pressed")
			if item.is_connected("moving_item", self, "move_item"):
				item.disconnect("moving_item", self, "move_item")
			if item.is_connected("item_preview", self, "preview_item"):
				item.disconnect("item_preview", self, "preview_item")
			item.queue_free()
	
	var cur_inv = get(window)
	for item in cur_inv:
		
		var item_data = dataparser.get_item(cur_inv[String(item)]["id"])		#Better open the dataparser script here.
		var slot = slot_scene.instance()
		if cur_inv[String(item)]["id"] != "0":		#Because item ID 0 is just an empty slot.
			slot.texture_path = item_data["icon"]		#Here we are accessing the data stored in the item database.
		slot.item_id = String(cur_inv[String(item)]["id"])
		slot.window = String(window)
		slot.set_name(String(item))
		slot.connect("slot_pressed", self, "slot_pressed")
		slot.connect("moving_item", self, "move_item")
		slot.connect("item_preview", self, "preview_item")
		get_node(String(window) + "/ScrollContainer/GridContainer").add_child(slot)

# warning-ignore:unused_argument
func _physics_process(delta):
	if Input.is_action_pressed("RMB"):
		rmb_pressed = true
	else:
		rmb_pressed = false

func slot_pressed(slot, window):
	set_process(true)
	is_dragging = true
	get_node(String(window) + "/ScrollContainer/GridContainer/" + String(slot) + "/item").hide()
	get_node("drag_item").texture = load(get_node(String(window) + "/ScrollContainer/GridContainer/" + String(slot)).texture_path)
	get_node("drag_item").rect_global_position = get_viewport().get_mouse_position() + Vector2(1, 1)
	get_node("drag_item").show() 
	dragged_item = String(slot)
	dragged_from_window = String(window)
	
# warning-ignore:unused_argument
func _process(delta):
	if is_dragging:
		get_node("drag_item").rect_global_position = get_viewport().get_mouse_position() + Vector2(1, 1)
		
func move_item(slot, window):
	if String(window) == String(dragged_from_window):
		if String(slot) == String(dragged_item):
			get_node(String(window) + "/ScrollContainer/GridContainer/" + String(dragged_item) + "/item").show()
			end_drag()
			return
		var cur_inv = get(window)
		if String(cur_inv[String(slot)]["id"]) == "0":
			cur_inv[String(slot)]["id"] = cur_inv[String(dragged_item)]["id"]
			cur_inv[String(dragged_item)]["id"] = "0"
			
		elif String(cur_inv[String(slot)]["id"]) != "0":
			var item = String(cur_inv[String(slot)]["id"])
			cur_inv[String(slot)]["id"] = cur_inv[String(dragged_item)]["id"]
			cur_inv[String(dragged_item)]["id"] = String(item)
			
		load_inv(window)
		end_drag()
		
	elif String(window) != String(dragged_from_window):
		var cur_inv = get(window)
		var prev_inv = get(dragged_from_window)	#Easier to acces like this
		
		if cur_inv[String(slot)]["id"] == "0":
			cur_inv[String(slot)]["id"] = prev_inv[String(dragged_item)]["id"]
			prev_inv[String(dragged_item)]["id"] = "0"
			load_inv(window)
			load_inv(dragged_from_window)
			end_drag()
			
		elif cur_inv[String(slot)]["id"] != "0":
			var prev_id = prev_inv[String(dragged_item)]["id"]
			prev_inv[String(dragged_item)]["id"] = cur_inv[String(slot)]["id"]
			cur_inv[String(slot)]["id"] = String(prev_id)
			load_inv(window)
			load_inv(dragged_from_window)
			end_drag()

func end_drag():
	dragged_from_window = null
	dragged_item = null
	is_dragging = false
	get_node("drag_item").hide()
	get_node("drag_item").texture = null
	set_process(false)

func preview_item(id):
	get_node("WindowDialog").rect_global_position = get_viewport().get_mouse_position()
	var item = dataparser.get_item(String(id))
	get_node("WindowDialog/Label").text = String(item["name"])
	get_node("WindowDialog").popup()
