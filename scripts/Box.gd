extends Actor

var images = [
	"res://assets/objects/box1.png",
	"res://assets/objects/box2.png",
	"res://assets/objects/box3.png"
]

func _ready():
	var image_path = images[round(rand_range(0,2))]
	$Sprite.texture = load(image_path)
