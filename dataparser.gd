extends Node

onready var file = File.new()
var url_database_items = "res://test_database.json" #write down the proper path to your item database here

func load_data(url):
	if url == null: return
	if !file.file_exists(url): return
	file.open(url, File.READ)
	var data = {}
	data = parse_json(file.get_as_text())
	file.close()
	return data
	#Simply said, this is able to load your .json and .bin files. I haven't tried other files.
	#Just keep in mind that this script has to be set as an autoload in the project settings. 
	
func write_data(url, dict):
	if url == null: return
	file.open(url, File.WRITE)
	file.store_line(to_json(dict))
	file.close()
	
func get_item(id):
	#Open the database, get the item (if it is there), close it and send the data to whatever function is requesting it.
	var item_data = {}
	item_data = load_data(url_database_items)
	
	if !item_data.has(String(id)):
		print("Item does not exists.")
		return
		
	item_data[String(id)]["id"] = int(id) #Just to keep the item ID accessible in the function you are calling it from
	return item_data[String(id)]