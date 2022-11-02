extends Resource

class_name SaveData

const PATH = "user://save"

export var project_list: Resource

func save_data():
	ResourceSaver.save(get_save_path(), self)
	

static func save_exists():
	return ResourceLoader.exists(get_save_path())
	
	
static func load_data():
	var save_path = get_save_path()
	if not ResourceLoader.has_cached(save_path):
		return ResourceLoader.load(save_path, "", true)
		
	var f = File.new()
	if f.open(save_path, File.File.READ) != OK:
		print("Cannot read file")
		return null


	var data = f.get_as_text()
	f.close()
	
	var tmp_file_path = make_random_path()
	while ResourceLoader.has_cached(tmp_file_path):
		tmp_file_path = make_random_path()
		
	if f.open(tmp_file_path, File.WRITE) != OK:
		print("Cannot write file")
		return null
		
	f.store_string(data)
	f.close()
	
	var save = ResourceLoader.load(tmp_file_path, "", true)
	save.take_over_path(save_path)
	
	var directory = Directory.new()
	directory.remove(tmp_file_path)
	return save
	
	
static func make_random_path() -> String:
	return "user://temp_file_" + str(randi()) + ".tres"
	
	
static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return PATH + extension
