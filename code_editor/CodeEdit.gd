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
	"love.conf",
	"love.displayrotated",
	"love.errorhandler",
	"love.load",
	"love.update",
	"love.draw",
	"love.quit",
	"love.run",
	"love.keypressed",
	"love.keyreleased",
	"love.textedited",
	"love.textinput",
	'love.mousepressed',
	"love.mousereleased",
	"love.mousemoved",
	"love.mousefocus",
	"love.wheelmoved",
	"love.touchmoved",
	"love.touchpressed",
	"love.touchreleased",
	"love.joystickpressed",
	"love.joystickreleased",
	"love.joystickaxis",
	"love.joystickhat",
	"love.joystickadded",
	"love.joystickremoved",
	"love.gamepadpressed",
	"love.gamepadreleased",
	"love.gamepadaxis",
	"love.resize",
	"love.visible",
	"love.focus",
	"love.filedropped",
	"love.directorydropped",
	"love.threaderror",
	"love.lowmemory",
]


func _ready() -> void:
	for i in lua_reserved_keyword:
		add_keyword_color(i, Color(0.269531, 0.589111, 1))
		
	for love in love_keyword:
		add_keyword_color(love, Color(1, 0.136719, 0.622314))
	
	
	add_color_region('"', '"', Color(1, 0.942413, 0.566406))
	add_color_region("'", "'", Color(1, 0.942413, 0.566406))
	add_color_region("--", "", Color(0.347656, 0.347656, 0.347656))



func _process(delta: float) -> void:
	pass
	


func _on_CodeEdit_request_completion() -> void:
	print("Request completion")
