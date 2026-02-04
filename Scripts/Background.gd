extends CanvasItem

var segment_v:int = 55.5 * 4
var segment_h:int = 47.5 * 4
var segment_wall_h:int
var segment_wall_v:int
var pillar = 4 * 4
var max_x: int
var max_y: int
var width:float = 14.0
var half_width:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	segment_wall_h = (segment_h*2) + (pillar*2)
	segment_wall_v = segment_v + (pillar * 2)
	max_x = (segment_h*5) + (pillar*2.5)
	max_y = (segment_v*3) + (pillar*4)
	half_width = width/2
	print(str(segment_h, ' ', segment_wall_h, ' ', segment_v, ' ', segment_wall_v))
	print(str(max_x,' ',max_y))

func _draw() -> void:
	var parent: CanvasItem = get_parent()
	#draw_set_transform_matrix(get_global_transform().affine_inverse())
	for y in [half_width, max_y+half_width]:
		draw_line(Vector2(0,y), Vector2(segment_wall_h,y), Color.RED, width)
		draw_line(Vector2(segment_wall_h+segment_h,y), Vector2(max_x + width, y), Color.GREEN, width)
	for x in [half_width, max_x+half_width]:
		draw_line(Vector2(x,0), Vector2(x,segment_wall_v), Color.RED, width)
		draw_line(Vector2(x,segment_wall_v+segment_v), Vector2(x,max_y + width), Color.RED, width)
		
	for y in [(width+half_width+segment_v), ((width+segment_v)*2)+half_width]:
		for i in range(1,5):
			var x = (width+segment_h)*i
			print (str(i,': ','(', x, ',', y, ')'))
			draw_line(Vector2(x,y), Vector2(x+width, y), Color.PURPLE, width)
