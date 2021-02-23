const util = preload("res://Scripts/Utility.gd");
const MetaData = preload('SongMetaData.gd');
const TimeStamp = preload('TimeStamp.gd');

static func fetch_all_meta_data_in_directory(directory):	
	var dir = Directory.new();
	var er = dir.open(directory);
	if(er):
		return null;
	
	var files = [];
	
	dir.list_dir_begin();
	
	var file_name = dir.get_next();
	while file_name != "":
		if(file_name.extension().to_lower() == "lrc"):			
			files.append(directory.plus_file(file_name));
		file_name = dir.get_next();
		
	dir.list_dir_end();
	
	var metaDataArray = [];
	
	for file in files:
		var data = fetch_meta_data_in_file(file);
		if(data):
			metaDataArray.push_back(data);
	
	var comparer = MetaDataComparer.new();	
	metaDataArray.sort_custom(comparer, "metaDataSorter");
	
	"""for data in metaDataArray:
		print(data.get_diag_display_string());"""
		
	return metaDataArray;
	
	
static func fetch_meta_data_in_file(filename):
	var file = File.new();
	if(!file.file_exists(filename)):
		print("Warning: Music metadata file \"" + str(filename) + "\" not found.");
		return null;
	
	var result = file.open(filename, File.READ);	
	
	if(result):	
		print("Warning: Cannot open file \"" + str(filename) + "\" Error code: " + str(result));
		return null;
		
	var title = "Untitled";
	var artist = "Unknown Artist";
	var album = "Unknown Album";
	var language = "EN";
	var length = TimeStamp.new(0);
	var difficulty = 1;
	var musicfile = "";
	var artfile = "";
	var relyear = "";
			
	var line = file.get_line();
	while !file.eof_reached() || !util.is_null_or_whitespace(line):
		line = line.strip_edges();
		if(line.length() <= 2 || line[0] != "[" || line[line.length() - 1] != "]"):		
			line = file.get_line();
			continue;
		
		var content = line.substr(1, line.length() - 2);		
		
		var firstColon = content.find(":");
		if(firstColon < 0 || firstColon == content.length() - 1):		
			line = file.get_line();
			continue;
		
		var id = content.substr(0, firstColon).strip_edges().to_lower();		
		var remainder = content.substr(firstColon + 1, content.length() - (firstColon + 1)).strip_edges();
		
		if(id == "ti"):
			title = remainder;
		elif(id == "ar"):
			artist = remainder;
		elif(id == "al"):
			album = remainder;
		elif(id == "length"):
			length = TimeStamp.parse(remainder);
		elif(id == "la"):
			language = remainder;
		elif(id == "relyear"):
			relyear = remainder;
		elif(id == "dif"):
			difficulty = int(remainder);
		elif(id == "file"):
			musicfile = remainder;
		elif(id == "art"):
			artfile = remainder;
		
		line = file.get_line();
	
	file.close();	
	
	if(util.is_null_or_whitespace(musicfile)):	
		print("Warning: Skipping loading metadata file \"" + str(filename) + "\" No music file specified.");
		return null;		
			
	var directmusicfile = filename.get_base_dir().plus_file(musicfile);
			
	if(!file.file_exists(directmusicfile)):
		print("Warning: Skipping loading metadata file \"" + str(filename) + "\" The music file \"" + str(musicfile) +"\" does not exist.");
		return null;
	var musicFileExtension = directmusicfile.extension().to_lower();
	if(musicFileExtension != "ogg" && musicFileExtension != "spx" &&musicFileExtension != "mpc"):
		print("Warning: Skipping loading metadata file \"" + str(filename) + "\" The music file \"" + str(musicfile) +"\" is not an ogg, spx, or mpc file.");
		return null;
		
	var directArtFile = null;
	if(util.is_null_or_whitespace(artfile)):
		print("Warning: No art file specified.");
	else:
		directArtFile = filename.get_base_dir().plus_file(artfile);		
		var artFileExtension = directArtFile.extension().to_lower();
			
		if(!file.file_exists(directArtFile)):
			print("Warning: Art file \"" + str(artfile) + "\" not found.");
			directArtFile = null;
		elif(artFileExtension != "png"):
			print("Warning: Skipping at file \"" + str(filename) + "\" The art file \"" + str(musicfile) +"\" is not a png file.");
			directArtFile = null;
		
	var metaData = MetaData.new(title, artist, album, relyear, language, length, difficulty, filename, directmusicfile, directArtFile);	
	
	if(length.seconds <= 0):
		var song = metaData.generate_song();
		
		if(song.words.size() > 0):
			var length = TimeStamp.new(song.words[song.words.size() - 1].start.seconds + 5);
			metaData.length = length;
			print("Warning: no length specified. Using calculated length of " + length.get_display_string());
	
	return metaData;
	

class MetaDataComparer:
	func metaDataSorter(a, b):
		if(a.difficulty != null && b.difficulty != null):
			if(a.difficulty < b.difficulty):
				return true;
			
			if(a.difficulty > b.difficulty):
				return false;
		
		if(a.artist != null && b.artist != null && a.artist != b.artist):
			return a.artist.casecmp_to(b.artist);
		
		if(!b.title):
			return true;
		if(!a.title):
			return false;
			
		return a.title.casecmp_to(b.title) < 0;
