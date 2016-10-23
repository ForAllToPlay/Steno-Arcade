const MainSplashScreenScene = "res://Scenes/StenoArcadeSplashScreen.scn";

const StenoHeroSplashScreenScene = "res://Steno Hero/Scenes/StenoHeroSongSelect.scn";
const StenoHeroGameScene = "res://Steno Hero/Scenes/StenoHeroGame.scn";

const MainScreen = "Main Splash Screen";
const StenoHero = "Steno Hero";

static func GetScene(sceneName):
	if(sceneName == MainScreen):
		return MainSplashScreenScene;
	elif(sceneName == StenoHero):
		return StenoHeroSplashScreenScene;
	else:
		return null;