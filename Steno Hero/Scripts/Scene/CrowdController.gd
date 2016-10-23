
extends Control

const AudienceMember = preload("res://Steno Hero/Prefabs/AudienceMember.scn");
const util = preload("res://Scripts/Utility.gd");

const CLOSEST_SCALE = 1;
const FARTHEST_SCALE = .85;

const MIN_DENSITY_PERCENT = 0;
const MAX_DENSITY_PERCENT = 1;

const MAX_AUDIENCE_PER_PIXEL_SQUARED = float(1) / (55 * 55);

const MIN_AUDIENCE_MEMBERS = 1;

var EdgeMarkerTop;
var EdgeMarkerBottom;
var CrowdContainer;

var GameController;
var PrecisionTracker;

const AUDIENCE_REEVAL_TIME = 3;
var evalCountdown;

var lastSpottedPrecision;
var lastCalculatedPrecision;

var AudienceMembers;

func _init():
	lastSpottedPrecision = .1;
	lastCalculatedPrecision = lastSpottedPrecision;

func _ready():
	CrowdContainer = get_node("CrowdContainer");
	EdgeMarkerTop = get_node("EdgeMarkerTop");
	EdgeMarkerBottom = get_node("EdgeMarkerBottom");

	GameController = get_node("/root/StenoHeroGame");
	
	var screenRef = GameController.get_node("ScreenRef");
	screenRef.connect(screenRef.SIZE_CHANGED, self, "_on_size_changed");
		
	PrecisionTracker = screenRef.get_node("Precision");	
	PrecisionTracker.connect(PrecisionTracker.PRECISION_CHANGED, self, "_on_precision_changed");

	evalCountdown = 0;
	AudienceMembers = [];
	
	set_process(true);
	_update_crowd(lastSpottedPrecision);

func _on_precision_changed(precision):
	if(!GameController.Started):
		return;
		
	lastSpottedPrecision = precision;
	if(evalCountdown <= 0):
		evalCountdown = AUDIENCE_REEVAL_TIME;
	
func _on_size_changed(newSize, oldSize):
	var containerSize = get_size();
		
	#If we've lost size, remove all the audience members past the cutoff
	if(oldSize.x > newSize.x):		
		var elementsToRemove = [];
		
		for member in AudienceMembers:
			if(member.get_pos().x > containerSize.x):
				elementsToRemove.append(member);
				
		for e in elementsToRemove:
			_remove_member_by_value(e, true);
			
		#Recalculate the crowd to ensure the audience numbers are now matching
		_update_crowd(lastCalculatedPrecision);
				
	#If we've gained size, add more members past the cutoff
	elif(oldSize.x < newSize.x):
		var addedSpace = (newSize.x - oldSize.x);
		
		var newAudienceCount = _calculate_audience_members(lastCalculatedPrecision, _calculate_current_area());		
		var missingAudience = max(newAudienceCount - AudienceMembers.size(), 0);
		
		#And add audience members if there are not enough
		for i in range(missingAudience):
			var z = randf();
			var newPos = Vector3(containerSize.x - addedSpace + util.randiMax(addedSpace), containerSize.y * z, z);
			
			_add_member(newPos, GameController.Started);			
		
		#Recalculate the crowd to ensure the audience numbers are now matching
		_update_crowd(lastCalculatedPrecision);
	
	
	
func _process(delta):
	if(evalCountdown > 0):
		evalCountdown -= delta;
		
		if(evalCountdown <= 0):
			_update_crowd(lastSpottedPrecision);

func _calculate_audience_members(precision, area):
	#Calculate what the density should be
	var curDensityPercent = lerp(MIN_DENSITY_PERCENT, MAX_DENSITY_PERCENT, clamp(precision, 0, 1));
	var audiencePerPixelSqr = curDensityPercent * MAX_AUDIENCE_PER_PIXEL_SQUARED;
	
	var targetAudienceMembers = max(round(audiencePerPixelSqr * area), MIN_AUDIENCE_MEMBERS);
	
	return targetAudienceMembers;
	
func _update_crowd(precision):
	lastCalculatedPrecision = precision;
	#First we need to determine how many crowd members there should be.
	
	#Calculate the area of the space
	var area = _calculate_current_area();	
	var targetAudienceMembers =_calculate_audience_members(precision, area);
	
	var audienceToAdd = max(targetAudienceMembers - AudienceMembers.size(), 0);
	
	#Now remove random audience members if there are too many
	while(AudienceMembers.size() > targetAudienceMembers):
		var index = util.randiMax(AudienceMembers.size());		
		_remove_member(index, false);
	
	#And add audience members if there are not enough
	for i in range(audienceToAdd):		
		var newPos = _generate_audience_member_position();		
		_add_member(newPos, false);

func _add_member(posAndDistance, immediate = false):
	var member = AudienceMember.instance();
	
	CrowdContainer.add_child(member);
	
	var newPos = posAndDistance;
	member.set_pos(Vector2(newPos.x, newPos.y));
	
	var scale = lerp(FARTHEST_SCALE, CLOSEST_SCALE, newPos.z);
	member.set_scale(Vector2(scale, scale));
	
	AudienceMembers.append(member);
	
	if(immediate):
		member.set_mode(member.IDLE_MODE, 0);	
	else:
		member.set_mode(member.READY_TO_ENTER_MODE, util.randfMax(AUDIENCE_REEVAL_TIME * .5));	
	
func _remove_member_by_value(member, immediate = false):
	_remove_member(AudienceMembers.find(member), immediate);
	
func _remove_member(index, immediate = false):
	if(index < 0 || index >= AudienceMembers.size()):
		return;
		
	var member = AudienceMembers[index];
	AudienceMembers.remove(index);
	
	if(immediate):
		member.queue_free();
	else:
		member.set_mode(member.READY_TO_BE_UNHAPPY, util.randfMax(AUDIENCE_REEVAL_TIME), util.randfRange(AUDIENCE_REEVAL_TIME * .75, AUDIENCE_REEVAL_TIME * 1.75));	

func _edge_marker_top_pos():
	return EdgeMarkerTop.get_pos() + EdgeMarkerTop.get_size() / 2;
	
func _edge_marker_bottom_pos():
	return EdgeMarkerBottom.get_pos() + EdgeMarkerBottom.get_size() / 2;
	
func _calculate_current_area():
	var pointA = _edge_marker_top_pos();
	var pointB = _edge_marker_bottom_pos();

	#Determine the area of the square
	var squareHeight = get_size().y;
	var squareWidth = get_size().x - max(pointA.x, pointB.x);
	var squareArea = squareWidth * squareHeight;
	
	#Determine the area of the triangle created by the edge markers
	var pointC;
	if(pointB.x > pointA.x):
		pointC = Vector2(pointB.x, pointA.y);
	else:
		pointC = Vector2(pointA.x, pointB.y);
		
	var vecA = pointA - pointC;
	var vecB = pointB - pointC;
	
	#Calculate the area by talking half of the cross product of the vectors
	var triangleArea = .5 * abs(vecA.x * vecB.y - vecA.y * vecB.x);
	
	var area = triangleArea + squareArea;
	return area;
	
func _generate_audience_member_position():
	#Determine the vertical position to use
	var verticalPercent = randf();
	
	#determine the far-left start position of this vertical percent
	var pos1 = _edge_marker_top_pos();
	var pos2 = _edge_marker_bottom_pos();
	
	var topPos;
	var bottomPos;
	
	if(pos1.y < pos2.y):
		topPos = pos1;
		bottomPos = pos2;
	else:
		topPos = pos2;
		bottomPos = pos1;
	
	var farLeftPos = topPos.linear_interpolate(bottomPos, verticalPercent);
	
	#now determine the far-right start position of this vertical percent
	var farRightPos = Vector2(get_size().x, farLeftPos.y);
	
	#determine the horizontal position to use
	var horizontalPercent = randf();
	
	#Finally, determine the spawn position
	var spawnPos = farLeftPos.linear_interpolate(farRightPos, horizontalPercent);
	
	return Vector3(spawnPos.x, spawnPos.y, verticalPercent);