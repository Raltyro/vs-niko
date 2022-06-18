package;

import flixel.FlxG;
import flixel.FlxBasic;
import haxe.Timer;
import openfl.Lib;

using Std;

class RaltTimer extends FlxBasic {
	public static var elapsed:Float = 0;
	public static var runtime:Float = 0;
	
	#if sys
	var starttime:Float;
	#else
	var timer:Timer;
	#end
	var prevtime:Float;
	
	override public function new() {
		super();
		
		#if sys
		starttime = Sys.time();
		#else
		timer = new Timer(10);
		timer.run = function() {
			runtime += .010;
		};
		#end
		prevtime = 0;
		update(0);
	}
	
	//override function kill() {
	//	super.kill();
	//	revive();
	//}
	
	override function update(bruh:Float) {
		#if sys
		runtime = Sys.time()-starttime;
		#end
		elapsed = runtime-prevtime;
		prevtime = runtime;
		
		//trace(bruh);
		super.update(elapsed);
		var fps = Std.int((1/elapsed));
		fps = (fps < 12) ? 12 : fps;
		fps = (fps > Std.int(openfl.Lib.current.stage.frameRate)) ? Std.int(openfl.Lib.current.stage.frameRate) : fps;
		//FlxG.updateFramerate = fps;
		//FlxG.drawFramerate = fps;
	}
}