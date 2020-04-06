extends Node2D

const LEFT_MARGIN = 250
const TOP_MARGIN = 40

var level
var jewelTextures = []

onready var cursor = $Cursor
onready var cursor_tween = $Cursor/Tween
onready var timer = $Timer
onready var score_label = $ScoreLabel

func get_item_location(x, y):
	return Vector2(x * 64 + LEFT_MARGIN, y * 64 + TOP_MARGIN)
	
func cursor_off():
	cursor.visible = false
	cursor_tween.stop(cursor)
	
func cursor_on(x, y):
	cursor.visible = true
	var location = get_item_location(x, y)
	location.x += 24
	location.y += 24
	cursor.position = location
	cursor_tween.interpolate_method(self, 'cursor_modulate', 0, 1, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	cursor_tween.start()
	
func cursor_modulate(value):
	var colour
	
	if value < 0.5:
		colour = Color(1, value * 2, 0, value * 2)
	else:
		colour = Color(1, (1 - value) * 2, 0, (1 - value) * 2)
		
	cursor.modulate = colour

func _ready():
	randomize()	

	var jewelTexture1 = load("res://images/Gems_01_64x64_001.png")
	var jewelTexture2 = load("res://images/Gems_01_64x64_002.png")
	var jewelTexture3 = load("res://images/Gems_01_64x64_003.png")
	var jewelTexture4 = load("res://images/Gems_01_64x64_011.png")
	var jewelTexture5 = load("res://images/Gems_01_64x64_012.png")
	var jewelTexture6 = load("res://images/Gems_01_64x64_013.png")
	var jewelTexture7 = load("res://images/Gems_01_64x64_022.png")
	var jewelTexture8 = load("res://images/Gems_01_64x64_024.png")
	var jewelTexture9 = load("res://images/Gems_01_64x64_026.png")
	var jewelTexture10 = load("res://images/Gems_01_64x64_014.png")

	jewelTextures.append(jewelTexture1)
	jewelTextures.append(jewelTexture2)
	jewelTextures.append(jewelTexture3)
	jewelTextures.append(jewelTexture4)
	jewelTextures.append(jewelTexture5)
	jewelTextures.append(jewelTexture6)
	jewelTextures.append(jewelTexture7)
	jewelTextures.append(jewelTexture8)
	jewelTextures.append(jewelTexture9)
	jewelTextures.append(jewelTexture10)

	var LEVEL = load("res://scripts/Level.gd")
	level = LEVEL.Level.new()
	level.initialise()
	
	# cursor_on(0, 0)
	cursor_off()
	
	timer.start()

func _draw():
	for y in range(0, 8):
		for x in range(0, 8):
			var item = level.map[y][x]
			if item != -1:
				draw_texture(jewelTextures[item], get_item_location(x, y))

func _input(event):
	if (event.is_pressed() and event is InputEventMouseButton):
		var x: int = (event.position.x - LEFT_MARGIN) / 64
		var y: int = (event.position.y - TOP_MARGIN) / 64
		cursor_on(x, y)
		if level.click(x, y):
			update()
		
	if Input.is_action_pressed("ui_reset"):
		level.initialise()
		update()
		
func _process(delta):
	score_label.text = 'Score: ' + str(level.score)

func on_timer_tick():
	if level.process():
		update()
