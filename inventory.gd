extends Node

var inventory = {}
onready var slot_scene = preload("res://slot_0.tscn") #the slot scene we are going to use.
var is_dragging = false
var dragged_item = null


	#IMPORTANT !!!
	#I used the following scene tree:
	
	#	Node		(holding this script)
	#		TextureRect
	#			ScrollContainer
	#				GridContainer
	#		TextureRect		(called drag_item)
	
	#Remember to set the drag_item node:
	#	Expand = true
	#	Stretch mode = Keep aspects centered
	
	#This will ensure that even diferent sized icons are always shown in the same size,
	#depending on rect_size setting on the drag_item node
	
	#You can customize the GridContainer with the number of columns, ScrollContainer in the scrolling way, etc.
func _ready():
	set_process(false)
	
	#Creating inventory as dictionary to store info like item ID or amount of that item on that slot
	for slot in range (0, 40):	#which means 40 inventory slots
		inventory[String(slot)] = {"id": "0"} 	#You can continue adding new keys with values here in the same style,
												#so it can actually look like this: {"id": "0", "amount": 0}
	
	#Now add some items to the inventory
	inventory["5"]["id"] = "1" 	#Where "5" is reference to the key in the Dictionary called and stored in var "inventory",
								#but it is too general and to access to ID key, you have to add the key you are looking for.
								#if you would be looking for amount, it would be inventory["5"]["amount"]
	inventory["12"]["id"] = "2"
	
	#Now the inventory itself is ready with some information, so let's load it to the game!
	load_inv()
	
func load_inv():
	#Because we are using instances of slot scene, at first we have to check if there are already instanced slots
	#and free them.
	if get_node("TextureRect/ScrollContainer/GridContainer").get_child_count() > 0:
		for item in get_node("TextureRect/ScrollContainer/GridContainer").get_children():
			item.set_name(item.name + "_terminating")		#Sometimes the function is faster that nodes which means
															#you can spawn news slots with the same name as the former
															#slots that are still in game. Not renaming the nodes can
															#cause invalid paths to nodes and their auto-renaming.
			item.disconnect("slot_pressed", self, "slot_pressed")	#I assume you know how the signals work in Godot.
			item.disconnect("moving_item", self, "move_item")
			item.queue_free()
	
	#Now we are sure that we can safely instance new slots to the inventory and assign some values to it.
	#Keep an eye on the slot scene itself as well, because in the end, you are now working with both scenes.
	for item in inventory:		#Or simply said for inventory slot that is contained in the inventory.
								#The most general key.
		var item_data = dataparser.get_item(inventory[String(item)]["id"])		#Better open the dataparser script here.
		var slot = slot_scene.instance()
		if inventory[String(item)]["id"] != "0":		#Because item ID 0 is just an empty slot.
			slot.texture_path = item_data["icon"]		#Here you we are accessing the data stored in the item database.
			slot.item_id = String(inventory[String(item)]["id"])
		slot.set_name(String(item))		#I decided to keep it simple and name the slot in the inventory by the slot
										#index in the var inventory. You can always try to put print(inventory) at the end
										#of this function to see what I mean.
		slot.connect("slot_pressed", self, "slot_pressed")
		slot.connect("moving_item", self, "move_item")
		get_node("TextureRect/ScrollContainer/GridContainer").add_child(slot)	#Oh yeah, welcome to the scene tree!
		#Now everything is prepared and can be seen in the game
		
func slot_pressed(slot):
	set_process(true)	#In this script, the _process(delta) is ensuring that the drag_item node is following mouse,
						#so there is no need for it to be active if you are not dragging anything.
	is_dragging = true
	get_node("TextureRect/ScrollContainer/GridContainer/" + String(slot) + "/item").hide()	#Now the 1st effect
		#takes place. This will hide the item texture on that slot you are dragging from.
	get_node("drag_item").texture = load(get_node("TextureRect/ScrollContainer/GridContainer/" + String(slot)).texture_path)
		#MAGIC! Just kidding. Since the texture in the slot scene is hidden, it would be great to see it on the mouse.
		#Well, now we are going to use the drag_item node to represent the item. This is simply duplicating the path
		#to the image so you can easily directly load it.
	get_node("drag_item").rect_global_position = get_viewport().get_mouse_position() + Vector2(1, 1)
		#You can try to erase + Vector2(1, 1), but trust me, if you are clicking the drag_item, you can't click
		#what's below. In Godot, all nodes are displayed in hiearchy starting from the top. So drag_item is above all.
	get_node("drag_item").show()
		#The drag_item was hidden so..., show it to the world now! :-) 
	dragged_item = String(slot)	#Better keep it for later use since the "slot" in this function is for this func
		# 1 time use only.
	
# warning-ignore:unused_argument
	#Trust me, these unused argument errors are annoying.
func _process(delta):
	if is_dragging:
		get_node("drag_item").rect_global_position = get_viewport().get_mouse_position() + Vector2(1, 1)
		#Let the drag_item node follow the mouse in (nearly) real time! 
		
func move_item(slot):
	if String(slot) == String(dragged_item):
		#If you want to put back what you have already taken..., why not, just put it back. This action simplifies
		#everything.
		is_dragging = false
		get_node("drag_item").hide()
		get_node("drag_item").texture = null
			#Just clear the drag_item node for later use. Just in case. Avoiding possible glitches in more
			#complicated scripts.
		set_process(false)
			#Remember what I said about using the process func in this script? Now is a good time to shut it down.
		get_node("TextureRect/ScrollContainer/GridContainer/" + String(dragged_item) + "/item").show()
			#Let the item be seen again in the slot it belongs to.
		dragged_item = null
		return
	is_dragging = false
	get_node("drag_item").hide()
	get_node("drag_item").texture = null
	set_process(false)
	if String(inventory[String(slot)]["id"]) == "0":
		#Slot in this function is the new one where you are trying to drop / put the item from different slot in inventory,
		#so at first, take all data from the previous slot (we stored it in the dragged_item, remember?) and then clear
		#the data from the previous slot. I've got only ID here, but for more keys just nearly duplicate the lines
		#and just change the ["id"] key to e.g. inventory[String(dragged_item)]["amount"] = 0, or whatever.
		inventory[String(slot)]["id"] = inventory[String(dragged_item)]["id"]
		inventory[String(dragged_item)]["id"] = "0"
	elif String(inventory[String(slot)]["id"]) != "0":
		#Use elif to use only one if statement from the whole function (but writing e.g. 3rd statement again with "if"
		# will break this rule and the engine WILL check it and not skip it.)
		
		#if the new slot has already an item assigned to it, you don't want to just erase it. So store the important
		#data in new vars, then again clear the dragged item and assign the items data from the new slot to the old one
		var item = String(inventory[String(slot)]["id"])
		inventory[String(slot)]["id"] = inventory[String(dragged_item)]["id"]
		inventory[String(dragged_item)]["id"] = String(item)
	dragged_item = null
	load_inv()
		#Here we are starting over again.