extends TextEdit

var lua_reserved_keyword = [
	"print",
	"require",
	"and",
	"break",
	"do",
	"else",
	"elseif",
	"end",
	"false",
	"for",
	"function",
	"if",
	"in",
	"local",
	"nil",
	"not",
	"or",
	"repeat",
	"return",
	"then",
	"true",
	"until",
	"while"
]

var love_keyword = [
	"self",
	"love",
	"conf",
	"displayrotated",
	"errorhandler",
	"load",
	"update",
	"draw",
	"quit",
	"run",
	"keypressed",
	"keyreleased",
	"textedited",
	"textinput",
	'mousepressed',
	"mousereleased",
	"mousemoved",
	"mousefocus",
	"wheelmoved",
	"touchmoved",
	"touchpressed",
	"touchreleased",
	"joystickpressed",
	"joystickreleased",
	"joystickaxis",
	"joystickhat",
	"joystickadded",
	"joystickremoved",
	"gamepadpressed",
	"gamepadreleased",
	"gamepadaxis",
	"resize",
	"visible",
	"focus",
	"filedropped",
	"directorydropped",
	"threaderror",
	"lowmemory",
	"graphics",
	"audio",
	"data",
	"event",
	"filesystem",
	"font",
	"image",
	"joystick",
	"keyboard",
	"math",
	"mouse",
	"physics",
	"sound",
	"system",
	"thread",
	"timer",
	"touch",
	"video",
	"window"
]

var current_line_length
var current_line
var last_line_length
var last_line


func _ready() -> void:
	for i in lua_reserved_keyword:
		add_keyword_color(i, Color(0.269531, 0.589111, 1))
		
	for love in love_keyword:
		add_keyword_color(love, Color(1, 0.136719, 0.622314))
	
	
	add_color_region('"', '"', Color(1, 0.942413, 0.566406))
	add_color_region("'", "'", Color(1, 0.942413, 0.566406))
	add_color_region("--", "", Color(0.347656, 0.347656, 0.347656))
	
	
	current_line_length = get_line_width(cursor_get_line())
	current_line = cursor_get_line()
	
	last_line_length = current_line_length
	last_line = current_line



func _process(delta: float) -> void:
	current_line_length = get_line_width(cursor_get_line())
	current_line = cursor_get_line()
	
	current_line_length = get_line_width(cursor_get_line())
	
	# If the text change and it's not delete word then
	if (current_line_length > last_line_length) and (last_line == current_line):
		add_pairs()
		current_line_length = get_line_width(cursor_get_line())
		
	
	last_line_length = current_line_length
	last_line = current_line


func _on_CodeEdit_request_completion() -> void:
	print("Request completion")


func _on_CodeEdit_text_changed() -> void:
#	add_pairs()
	pass
	
	
func add_pairs():
	var cursor_pos = Vector2(cursor_get_line(), cursor_get_column())
	select(cursor_pos.x, cursor_pos.y - 1, cursor_pos.x, cursor_pos.y)
	var character = get_selection_text()
	match character:
		"(":
			deselect()
			insert_text_at_cursor(")")
			
		"[":
			deselect()
			insert_text_at_cursor("]")
			
		"{":
			deselect()
			insert_text_at_cursor("}")
			
		"'":
			deselect()
			insert_text_at_cursor("'")
			
		'"':
			deselect()
			insert_text_at_cursor('"')
			
	cursor_set_column(cursor_pos.y)
	deselect()


