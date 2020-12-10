extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var texture_preview = $Panel/Panel2/TextureRect

var items = {}
onready var tree = find_node("Tree")


# Called when the node enters the scene tree for the first time.
func _ready():
	$FileDialog.popup_centered()
	$FileDialog.connect("dir_selected", self, "_on_dir_selected")
	$FileDialog.connect("file_selected", self, "_on_file_selected")
	

	
func _on_file_selected(file_path : String):
	
	if file_path.ends_with(".png"):
		var image = Image.new()
		image.load(file_path)

		var texture = ImageTexture.new()
		texture.create_from_image(image, 0)
		
		texture_preview.texture = texture
	
	
func _on_dir_selected(dir_path):
	pass


func _on_Tree_button_pressed(item, column, id):
	pass # Replace with function body.


func _on_Tree_item_selected():
	var path = tree.items_path[tree.get_selected()]
	_on_file_selected(path)
	
