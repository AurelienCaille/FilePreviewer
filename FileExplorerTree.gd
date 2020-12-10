extends Tree

var current_dir
var base_dir_path = "C:/Users/aur-l/OneDrive/Images"
var current_view
var _cache_collapsed = {}
var items_path = {}

func _ready():
	current_dir = Directory.new()
	current_dir.open(base_dir_path)
	
	refresh_tree()

func refresh_tree():
	if self.get_root():
		cache_collapsed()
		self.clear()
		
	var dir = current_dir
	_create_tree(null, dir)
	
	#if current_view and current_view.hide_empty_dirs:
	#	_clean_empty_dir(self.get_root())
	
	#if current_view.name and _cache_collapsed.has(current_view.name):
	#	_set_folder_collapsed(self.get_root(), false, _cache_collapsed[current_view.name])

func _set_folder_collapsed(current:TreeItem, collapsed:bool, excepts = null):
	var item: TreeItem = current.get_children()
	
	while item:
		var path : String = item.get_metadata(0)
		if path.ends_with("/"):
			_set_folder_collapsed(item, collapsed, excepts)
			if excepts and path in excepts:
				item.collapsed = not collapsed
			else:
				item.collapsed = collapsed
		item = item.get_next()

func _clean_empty_dir(current: TreeItem):
	var should_clean = true
	
	var item: TreeItem = current.get_children()
	while item:
		var path : String = item.get_metadata(0)
		if path.ends_with("/"):
			if _clean_empty_dir(item):
				current.remove_child(item)
			else:
				should_clean = false
		else:
			return false
		item = item.get_next()
		
	return should_clean

func _create_tree(parent: TreeItem, current: Directory, recursion=5):
	if recursion <= 0:
		return
	var item = self.create_item(parent)
	var dname = current.get_current_dir()
	if dname == "":
		dname = "res://"
		
	item.set_text(0, dname)
	item.set_selectable(0, true)
	item.set_icon(0, get_icon("Folder", "EditorIcons"));
	item.set_icon_modulate(0, self.get_color("folder_icon_modulate", "FileDialog"));
	
	var dir_path : String = current.get_current_dir()
	item.set_metadata(0, dir_path)
	
	current.list_dir_begin(true, true)
	
	var file_name : String = current.get_next()
	var i = 0
	while file_name != "":
		if current.current_is_dir():
			var sub_directory = Directory.new()
			sub_directory.open(file_name)
			print("Found directory: " + file_name)
			_create_tree(item, sub_directory, recursion-1)
		else:
			print("Found file: " + file_name)
			
			var file_item = self.create_item(item)
			file_item.set_text(0, file_name.get_file())
			items_path[file_item] = dir_path.plus_file(file_name)
		file_name = current.get_next()

	"""
	for i in current.get_subdir_count():
		_create_tree(item, current.get_subdir(i))
	
	for i in current.get_file_count():
		var file_name = current.get_file(i)
		var file_path = dir_path.plus_file(file_name)
		
		if current_view and not current_view.is_match(file_path):
			continue
		
		var file_type = current.get_file_type(i)
		var file_item = self.create_item(item)
		file_item.set_text(0, file_name)
		file_item.set_icon(0, _get_tree_item_icon(current, i))
		
		file_item.set_metadata(0, file_path)
	"""
		
func _get_tree_item_icon(dir: Directory, idx: int) -> Texture:
	var icon : Texture
	if not dir.get_file_import_is_valid(idx):
		icon = get_icon("ImportFail", "EditorIcons")
	else:
		var file_type = dir.get_file_type(idx)
		if has_icon(file_type, "EditorIcons"):
			icon = get_icon(file_type, "EditorIcons")
		else:
			icon = get_icon("File", "EditorIcons")
	return icon
		
func cache_collapsed():
	var root = self.get_root()	
	if not current_view.name or not root:
		return
	var list = []
	_cache_collapsed_list(root, list)
	_cache_collapsed[current_view.name] = list


func _cache_collapsed_list(parent: TreeItem, list: Array):
	var item: TreeItem = parent.get_children()
	while item: 
		var path : String = item.get_metadata(0)
		if path.ends_with("/"):
			_cache_collapsed_list(item, list)
			if item.collapsed:
				list.append(path)
		item = item.get_next()
