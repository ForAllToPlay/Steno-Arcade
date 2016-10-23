
extends TextureFrame

const util = preload("res://Scripts/Utility.gd");
const Cloud = preload("res://Steno Hero/Prefabs/Cloud.scn");

var ScreenRef;

const MIN_TIME_BETWEEN_CLOUDS = 4;
const MAX_TIME_BETWEEN_CLOUDS = 15;

const CLOUDS_PER_PIXEL = 1.0 / 150.0;

var spawnTimer;

func _ready():
	spawnTimer = util.randfRange(MIN_TIME_BETWEEN_CLOUDS, MAX_TIME_BETWEEN_CLOUDS);
	
	set_process(true);
	pass
	
func _enter_tree():
	ScreenRef = get_node("/root/StenoHeroGame/ScreenRef");

	ScreenRef.connect(ScreenRef.SIZE_CHANGED, self, '_on_size_changed');
	pass
	
func _on_size_changed(new, old):
	
	for child in get_children():
		child.queue_free();

	var cloudCount = int(CLOUDS_PER_PIXEL * new.x);
	for i in range(cloudCount):
		_spawn_cloud(new.x);			
	pass

func _process(delta):
	spawnTimer -= delta;
	if(spawnTimer <= 0):
		spawnTimer = util.randfRange(MIN_TIME_BETWEEN_CLOUDS, MAX_TIME_BETWEEN_CLOUDS);
		_spawn_cloud(0);
	pass
	
func _spawn_cloud(maxX):
	var cloud = Cloud.instance();
	cloud.ScreenRef = ScreenRef;
	
	cloud.set_pos(Vector2(util.randiMax(maxX) - cloud.get_texture().get_width() * cloud.get_scale().x * .5, util.randiMax(int(ScreenRef.get_size().y * .33))));
	
	add_child(cloud);	


