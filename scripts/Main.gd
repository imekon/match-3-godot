extends Node2D

const LEFT_MARGIN = 250
const TOP_MARGIN = 40

var level
var jewelTextures = []

onready var cursor = $Cursor
onready var cursor_tween = $Cursor/Tween
onready var timer = $Timer
onready var score_label = $ScoreLabel

enum LEVEL_STATE { Idle, FirstClick, SecondClick }

class Level:
	var map = []
	var state = LEVEL_STATE.Idle
	var score = 0
	var first = Vector2(-1, -1)
	var second = Vector2(-1, -1)
	
	const scores = [ 10, 15, 20, 30, 40, 50, 70, 100, 150, 500 ]

	func _init():
		for y in range(0, 8):
			var row = []
			for x in range(0, 8):
				row.append(-1)
			map.append(row)
			
	func make_map_array(value):
		var m = []
		for y in range(0, 8):
			var row = []
			for x in range(0, 8):
				row.append(value)
			m.append(row)
		return m
		
	func print_map(m):
		for y in range(0, 8):
			var text = ''
			for x in range(0, 8):
				var item = m[y][x]
				text += str(item) + ' '
			print(text)
			
	func get_random_item():
		var result = -1
		var val = randi() % 100
		if val > 99:
			result = 9
		else:
			if val > 90:
				result = 8
			else:
				result = randi() % 8
		return result
		
	func initialise():
		for y in range(0, 8):
			for x in range(0, 8):
				map[y][x] = get_random_item()
		# print_map(map)
				
	func look_right(x, y):
		if x > 5:
			return 0
			
		var count = 1
		var starting = map[y][x]
		for lookX in range(x + 1, 8):
			if map[y][lookX] == starting:
				count += 1
			else:
				break
				
		return count
		
	func look_down(x, y):
		if y > 5:
			return 0
			
		var count = 1
		var starting = map[y][x]
		for lookY in range(y + 1, 8):
			if map[lookY][x] == starting:
				count += 1
			else:
				break
				
		return count
		
	func delete_items_right(x, y, count):
		for lookX in range(x, x + count):
			if lookX >= 0 and lookX < 8:
				var item = map[y][lookX]
				if item != -1:
					process_score(item)
				map[y][lookX] = -1
		
	func delete_items_down(x, y, count):
		for lookY in range(y, y + count):
			if lookY >= 0 and lookY < 8:
				var item = map[lookY][x]
				if item != -1:
					process_score(item)
				map[lookY][x] = -1
		
	func look(right_map, down_map):
		for y in range(0, 8):
			for x in range(0, 8):
				right_map[y][x] = look_right(x, y)
				down_map[y][x] = look_down(x, y)
		# print('right')
		# print_map(right_map)
		# print('down')
		# print_map(down_map)
				
	func delete_items(right_map, down_map):
		# print('delete items')
		for y in range(0, 8):
			for x in range(0, 8):
				if right_map[y][x] >= 3:
					delete_items_right(x, y, right_map[y][x])
				if down_map[y][x] >= 3:
					delete_items_down(x, y, down_map[y][x])
					
	func drop_down_column(x, y):
		if y < 1:
			return false
			
		if map[y][x] != -1:
			return false
		
		map[y][x] = map[y - 1][x]
		map[y - 1][x] = -1
		return true
					
	func drop_down():
		var result = false
		for y in range(7, 0, -1):
			for x in range(0, 8):
				if drop_down_column(x, y):
					result = true
		return result
		
	func fill_at_top():
		var result = false
		for x in range(0, 8):
			if map[0][x] == -1:
				map[0][x] = get_random_item()
				result = true
		return result
				
	func process():
		var right_map = make_map_array(0)
		var down_map = make_map_array(0)
		look(right_map, down_map)
		delete_items(right_map, down_map)
		var update = drop_down()
		if fill_at_top():
			update = true
		return update
		
	func process_score(item):
		score += scores[item]
		
	func swap_items():
		if first.x == -1 || first.y == -1 || second.x == -1 || second.y == -1:
			return false
			
		var item1 = map[first.y][first.x]
		var item2 = map[second.y][second.x]
		map[first.y][first.x] = item2
		map[second.y][second.x] = item1
		set_state_idle()
		return true
		
	func set_state_first(x, y):
		state = LEVEL_STATE.FirstClick
		first = Vector2(x, y)
		return false
		
	func set_state_second(x, y):
		state = LEVEL_STATE.SecondClick
		second = Vector2(x, y)
		return swap_items()
		
	func set_state_idle():
		state = LEVEL_STATE.Idle
		first = Vector2(-1, -1)
		second = Vector2(-1, -1)
		return false
		
	func click(x, y):
		match state:
			LEVEL_STATE.Idle:
				return set_state_first(x, y)
			LEVEL_STATE.FirstClick:
				return set_state_second(x, y)
			LEVEL_STATE.SecondClick:
				return set_state_idle()
	
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

	level = Level.new()
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
