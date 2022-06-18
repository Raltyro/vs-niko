package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.system.FlxSound;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import haxe.io.Path;
import openfl.Lib;
#if desktop
import webm.*;
#end

using StringTools;

class VideoState extends MusicBeatState {
	public var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
	public var webmHandler:WebmHandler;
	public var vHandler:VideoHandler;
	public var videoSprite:FlxSprite = new FlxSprite();
	
	public var filePath:String;
	public var transClass:FlxState;
	public var fuckingVolume:Float = 1;
	public var notDone:Bool = true;
	public var vidSound:FlxSound;
	public var useSound:Bool = false;
	public var soundMultiplier:Float = 1;
	public var prevSoundMultiplier:Float = 1;
	public var videoFrames:Int = 0;
	public var fixr:Int = 0;
	public var doShit:Bool = false;
	public var autoPause:Bool = false;
	public var musicPaused:Bool = false;
	public var firsttime:Bool = true;
	public var txtdata:Array<String>;
	private var defaultskiplimit = WebmPlayer.SKIP_STEP_LIMIT;

	public function new(fileName:String,toTrans:FlxState,frameSkipLimit:Int = -1,autopause:Bool = false) {
		super();

		autoPause = autopause;

		filePath = fileName;
		transClass = toTrans;
		if (GlobalVideo.isWebm) {
			WebmPlayer.SKIP_STEP_LIMIT = defaultskiplimit;
			if (frameSkipLimit != -1)
				WebmPlayer.SKIP_STEP_LIMIT = frameSkipLimit;
		}
	}

	override function create() {
		super.create();
		if (firsttime) {
			if (GlobalVideo.isWebm) {
				var str = "WEBM SHIT";
				webmHandler = new WebmHandler();
				webmHandler.source(ourSource);
				webmHandler.makePlayer();
				webmHandler.webm.name = str;
				GlobalVideo.setWebm(webmHandler);
			}
			else {
				var str = "HTML CRAP";
				vHandler = new VideoHandler();
				vHandler.init1();
				vHandler.video.name = str;
				vHandler.init2();
				vHandler.source(ourSource);
				GlobalVideo.setVid(vHandler);
			}
		}
		if (GlobalVideo.isWebm) {
			GlobalVideo.setWebm(webmHandler);
		}
		else {
			GlobalVideo.setVid(vHandler);
		}
		notDone = true;
		FlxG.autoPause = false;
		doShit = false;
		
		txtdata = (Assets.getText(filePath.replace(".webm",".txt"))).split(':');
		videoFrames = Std.parseInt(txtdata[0]);
		fixr = Std.parseInt(txtdata[1]);
		
		fuckingVolume = FlxG.sound.music.volume;
		FlxG.sound.music.volume = 0;
		
		if (Assets.exists(filePath.replace(".webm", ".ogg"), MUSIC) || Assets.exists(filePath.replace(".webm", ".ogg"), SOUND)) {
			useSound = true;
			vidSound = FlxG.sound.play(filePath.replace(".webm", ".ogg"));
		}
		
		GlobalVideo.get().source(filePath);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
			GlobalVideo.get().updatePlayer();
		
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm) {
			GlobalVideo.get().restart();
			videoSprite.loadGraphic(webmHandler.webm.bitmapData);
			
			//doesnt work once again :/
			if (fixr == 0)
				videoSprite.setGraphicSize(Std.int(GameDimensions.width),Std.int(GameDimensions.height));
			else //{
				//if (FlxG.width>FlxG.height)
					videoSprite.setGraphicSize(Std.int(GameDimensions.width));
				//else
				//	videoSprite.setGraphicSize(Std.int(FlxG.height));
			//}
			videoSprite.screenCenter();
			add(videoSprite);
		}
		else {
			GlobalVideo.get().play();
			vHandler.video.height = Std.int(GameDimensions.height);
			
			//idk about this one, i dont know how to compile shit to html5
			if (fixr == 0)
				vHandler.video.width = Std.int((vHandler.video.videoWidth/vHandler.video.videoHeight)*GameDimensions.width);
			else {
				vHandler.video.width = Std.int(GameDimensions.width);
			}
			FlxG.addChildBelowMouse(vHandler.video);
		}
		
		vidSound.time = vidSound.length * soundMultiplier;
		doShit = true;

		if (autoPause && FlxG.sound.music != null && FlxG.sound.music.playing) {
			musicPaused = true;
			FlxG.sound.music.pause();
		}
		GlobalVideo.get().resume();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		
		if (useSound) {
			var wasFuckingHit;
			if (GlobalVideo.isWebm) {
				wasFuckingHit = GlobalVideo.get().webm.wasHitOnce;
				soundMultiplier = GlobalVideo.get().webm.renderedCount / videoFrames;
			}
			else {
				wasFuckingHit = GlobalVideo.get().video.wasHitOnce;
				soundMultiplier = GlobalVideo.get().video.renderedCount / videoFrames;
			}
			if (soundMultiplier > 1)
				soundMultiplier = 1;
			
			if (soundMultiplier < 0)
				soundMultiplier = 0;
			
			if (doShit) {
				var compareShit:Float = 50;
				if (vidSound.time >= (vidSound.length * soundMultiplier) + compareShit
					|| vidSound.time <= (vidSound.length * soundMultiplier) - compareShit)
					vidSound.time = vidSound.length * soundMultiplier;
			}
			if (wasFuckingHit) {
				if (soundMultiplier == 0) {
					if (prevSoundMultiplier != 0) {
						vidSound.pause();
						vidSound.time = 0;
					}
				} else {
					if (prevSoundMultiplier == 0) {
						vidSound.resume();
						vidSound.time = vidSound.length * soundMultiplier;
					}
				}
				prevSoundMultiplier = soundMultiplier;
			}
		}
		
		if (notDone)
			FlxG.sound.music.volume = 0;
		
		GlobalVideo.get().update(elapsed,fixr);

		if (controls.ACCEPT || GlobalVideo.get().ended || GlobalVideo.get().stopped) {
			GlobalVideo.get().hide();
			GlobalVideo.get().stop();
		}

		if (controls.ACCEPT || GlobalVideo.get().ended) {
			notDone = false;
			FlxG.sound.music.volume = fuckingVolume;
			FlxG.autoPause = true;
			GlobalVideo.get().stop();
			if (musicPaused) {
				musicPaused = false;
				FlxG.sound.music.resume();
			}
			firsttime = false;
			if (GlobalVideo.isWebm)
				remove(videoSprite);
			else
				FlxG.removeChild(vHandler.video);
			GlobalVideo.get().source(ourSource);
			FlxG.switchState(transClass);
		}

		if (GlobalVideo.get().played || GlobalVideo.get().restarted)
			GlobalVideo.get().show();

		GlobalVideo.get().restarted = false;
		GlobalVideo.get().played = false;
		GlobalVideo.get().stopped = false;
		GlobalVideo.get().ended = false;
	}
}