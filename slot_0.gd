extends TextureRect

signal slot_pressed
signal moving_item
signal item_preview

var window = null
var texture_path = null		#updated by the inventory script as well as var item_id
var item_id = "0"

	#IMPORTANT !!!
	#I used the following scene tree:
	
	#	TextureRect		(holding this script)
	#		TextureRect		(called "item", in my test project)
	#			TextureButton

	#The 1st TextureRect, on the top of the scene, is holding the inventory slot texture.
	#The 2nd TextureRect, called item, is the one representating the item this slot holds.
	
	#It is necessary to connect the button_pressed signal from the node TextureButton and
	#set the focus mode to none on it, just in case.
	
	#Remember to set the 2nd TextureRect node:
	#	Expand = true
	#	Stretch mode = Keep aspects centered
	
	# In my test project, I used inventory slot texture sized 54x54, so I set the 2nd TextureRect
	# and TextureButton to the size of 50x50 and set their rect position to Vector2(2, 2), just to put
	# these nodes in the middle of the slot.
	
func _ready():
	#the texture_path is set even before this node is added to the scene tree,
	#so don't be afraid to set the item texture now
	if texture_path != null:
		get_node("item").texture = load(String(texture_path))
		#Because try to load a null path...

func _on_TextureButton_pressed():
	if item_id != "0":
		if get_parent().get_parent().get_parent().get_parent().rmb_pressed == true:
			emit_signal("item_preview", item_id)
			return
	if get_parent().get_parent().get_parent().get_parent().is_dragging == true:
		emit_signal("moving_item", name, window)
		return
		#If you are already dragging an item, you should not start to drag another one. Usually it is about droping
		#the item somewhere.
	else:
		if item_id == "0":
			#Empty slot item is hard to see in general. This item still doesn't have any values anyway.
			return
		emit_signal("slot_pressed", name, window)
		#So you haven't been dragging anything, but you pressed the item..., so you want to drag an item in the end, right?
