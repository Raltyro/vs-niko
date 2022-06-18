// I need pills to relieve my stress from syntax errors and memory leaks.
// edit: ok well i dont have to, it was easy to fix

package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.util.FlxColor;
//import flixel.text.FlxTextBorderStyle;
import lime.app.Application;
import Main.ExitState;
import openfl.display.FPS;
import openfl.Lib;
import RaltTimer;

using StringTools;
using Std;

#if windows
import Discord.DiscordClient;
#end

class CustomMenu extends MusicBeatState {
	static var initialized:Bool = false;
	
	var decisions:Array<Dynamic>;
	var items:FlxTypedGroup<FlxSprite>;
	var decisionPoint:FlxSprite;
	var curDecision:Array<Int> = [0,0,0];
	var curDeStep:Int = 0;
	var itemtitle:FlxText;
	
	//maybe temporary
	var songs:Array<String> = ['Blue Phosphor','Amber','Refuge'];
	
	var bg:FlxSprite;
	var bgParticles:FlxSprite;
	var bgParticles2:FlxSprite;
	var topGradient:FlxSprite;
	var luminance:FlxSprite;
	var niko:FlxSprite;
	var logo:FlxSprite;
	var camFollow:FlxObject;
	
	/*function arrayaccessiterator(it:Iterator<Dynamic>,v:Int) {
		var c:Int = 0;
		var chosen:Null<Dynamic> = false;
		if (it.hasNext()) {
			for (i in it) {
				if (c == v) chosen = i;
				c++;
			}
		}
		return chosen;
	}
	*/
	override public function create() {
		decisions = [
			['Play',[
				['Hard',''],
				['Normal',''],
				['Easy',''],
				['Previous','']
			]],
			['Options',''],
			['Credits',''],
			['Exit','']
		];
		if (FlxG.save.data.niko_curprogress != null)
			decisions[0] = ['Continue',''];
	
		#if windows
		DiscordClient.changePresence("MAIN MENU",null);
		#end
		
		bg = new FlxSprite().loadGraphic(Paths.image('extras/mainmenu/bg','preload'));
		bg.setGraphicSize(2600);
		bg.screenCenter();
		bg.scrollFactor.set(.1,.1);
		
		bgParticles = new FlxSprite().loadGraphic(Paths.image('extras/mainmenu/bgParticles','preload'));
		bgParticles.setGraphicSize(1320);
		bgParticles.screenCenter();
		bgParticles.scrollFactor.set(.3,.3);
		bgParticles2 = new FlxSprite(bgParticles.x,bgParticles.y+bgParticles.height-230).loadGraphic(Paths.image('extras/mainmenu/bgParticles','preload'));
		bgParticles2.setGraphicSize(1320);
		bgParticles2.scrollFactor.set(.3,.3);
		
		topGradient = new FlxSprite().loadGraphic(Paths.image('extras/mainmenu/topGradient','preload'));
		topGradient.setGraphicSize(2600);
		topGradient.screenCenter();
		topGradient.scrollFactor.set(0,0);
		
		luminance = new FlxSprite().loadGraphic(Paths.image('extras/mainmenu/luminance','preload'));
		luminance.setGraphicSize(2600);
		luminance.screenCenter();
		luminance.scrollFactor.set(.2,.2);
		
		niko = new FlxSprite(FlxG.width * .4,FlxG.height * .23).loadGraphic(Paths.image('extras/mainmenu/niko','preload'));
		niko.setGraphicSize(370);
		niko.scrollFactor.set(.5,.5);
		
		logo = new FlxSprite(-FlxG.width * .33,-FlxG.height * .45).loadGraphic(Paths.image('extras/mainmenu/logo','preload'));
		logo.setGraphicSize(560);
		logo.scrollFactor.set(.64,.64);
		
		if (FlxG.save.data.antialiasing) {
			bg.antialiasing = true;
			bgParticles.antialiasing = true;
			bgParticles2.antialiasing = true;
			topGradient.antialiasing = true;
			luminance.antialiasing = true;
			niko.antialiasing = true;
			logo.antialiasing = true;
		}
		
		add(bg);
		add(bgParticles);
		add(bgParticles2);
		add(topGradient);
		add(luminance);
		add(niko);
		add(logo);
		
		items = new FlxTypedGroup<FlxSprite>();
		add(items);
		
		camFollow = new FlxObject(0,0, 1, 1);
		add(camFollow);
		
		decisionPoint = new FlxSprite(23,0).loadGraphic(Paths.image('extras/decision','preload'));
		decisionPoint.setGraphicSize(32);
		decisionPoint.scrollFactor.set(0,0);
		
		itemtitle = new FlxText(75,(FlxG.height * .725) - 50, FlxG.width, "Main", 48);
		itemtitle.font = 'VCR OSD Mono';
		itemtitle.color = 0xFFFFFFFF;
		itemtitle.scrollFactor.set(0,0);
		itemtitle.antialiasing = FlxG.save.data.antialiasing;
		add(itemtitle);
		
		makeDecisions();
		add(decisionPoint);
		
		FlxG.camera.follow(camFollow,null,.015 * (120/FlxG.save.data.fpsCap));
		camFollow.setPosition(FlxG.width / 2,FlxG.height / 2);
		
		super.create();
		persistentUpdate = true;
		
		var ogpy = bgParticles.y;
		var ogpy2 = bgParticles2.y;
		FlxTween.linearMotion(bgParticles2,bgParticles2.x,ogpy2,bgParticles2.x,ogpy,22,true);
		FlxTween.linearMotion(bgParticles,bgParticles.x,ogpy,bgParticles.x,ogpy-bgParticles.height+230,22,true);
		new FlxTimer().start(22,function(tmr:FlxTimer) {
			FlxTween.linearMotion(bgParticles2,bgParticles2.x,ogpy2,bgParticles2.x,ogpy,22,true);
			FlxTween.linearMotion(bgParticles,bgParticles.x,ogpy,bgParticles.x,ogpy-bgParticles.height+230,22,true);
		},0);
		
		changeItem();changeItem();
		if (!initialized) {
			FlxG.sound.playMusic(Paths.music(Oneshot.perma_flags[9] ? 'extras/menuloop-after' : 'extras/menuloop','preload'),1);
			Conductor.changeBPM(64);
			initialized = true;
		}
	}
	
	var finished:Bool = false;
	var runtime:Float = -1000000;
	var idklol2:Array<Float> = [-1000000,-1000000];
	var idklol3:Array<Bool> = [false,false];
	var idklol:Float = 1;
	override function update(elapsed:Float) {
		super.update(elapsed);
		FlxG.camera.follow(camFollow,null,.015 * (120/(1/elapsed)));
		
		runtime += elapsed / 2;
		idklol += elapsed;
		//if (runtime > 1000000) runtime = -1000000;
		
		camFollow.setPosition(
			((Math.cos(runtime) + Math.cos(runtime / 2)) * 7) + (curDeStep * 4) + (FlxG.width / 2),
			(((Math.cos(runtime / 2.1) + Math.sin(runtime / 1.5)) * 5) + ((curDecision[curDeStep] - 2) * 7)) + (FlxG.height / 2)
		);
		logo.setPosition(-FlxG.width * .33,(-FlxG.height * .45) + (Math.cos(runtime / 2) * 9));
		
		luminance.alpha = .625+(Math.cos(runtime) * .175);
		bgParticles.alpha = .75+(Math.cos(runtime - 1) * .125);
		bgParticles2.alpha = .75+(Math.cos(runtime - 1) * .125);
		
		if (idklol > .25) changeItem();
		
		if (!finished) {
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
			if (gamepad != null) {
				if (gamepad.pressed.DPAD_UP && runtime > idklol2[1]) {
					idklol2[1] = runtime+.07;
					if (!idklol3[1]) idklol2[1] += .43;
					changeItem(-1);
				}
				if (!gamepad.pressed.DPAD_UP) idklol2[1] = runtime;
				if (gamepad.pressed.DPAD_DOWN && runtime > idklol2[0]) {
					idklol2[0] = runtime+.07;
					if (!idklol3[0]) idklol2[0] += .43;
					changeItem(1);
				}
				if (!gamepad.pressed.DPAD_DOWN) idklol2[0] = runtime;
				
				idklol3[0] = gamepad.pressed.DPAD_UP;
				idklol3[1] = gamepad.pressed.DPAD_DOWN;
			}
			else {
				if (FlxG.keys.pressed.UP && runtime > idklol2[1]) {
					idklol2[1] = runtime+.07;
					if (!idklol3[1]) idklol2[1] += .43;
					changeItem(-1);
				}
				if (!FlxG.keys.pressed.UP) idklol2[1] = runtime;
				if (FlxG.keys.pressed.DOWN && runtime > idklol2[0]) {
					idklol2[0] = runtime+.07;
					if (!idklol3[0]) idklol2[0] += .43;
					changeItem(1);
				}
				if (!FlxG.keys.pressed.DOWN) idklol2[0] = runtime;
				
				idklol3[0] = FlxG.keys.pressed.DOWN;
				idklol3[1] = FlxG.keys.pressed.UP;
			}
			
			if (controls.BACK) {
				if (curDeStep > 0) {
					curDecision[curDeStep] = -1;
					changeItem();
				}
				else {
					curDecision[curDeStep] = 0;
					changeItem(-1);
				}
			}
			
			if (controls.ACCEPT || (controls.BACK && curDeStep > 0)) {
				var chosen = decisions;
				var str = '';
				if (curDeStep > 0) {
					for (i in 0...curDeStep) {
						str = str + chosen[curDecision[i]][0] + ".";
						chosen = chosen[curDecision[i]][1];
					}
					//chosen = chosen[curDecision[curDeStep]];
				}
				str = str + chosen[curDecision[curDeStep]][0];
				
				if (chosen[curDecision[curDeStep]][0] == "Previous") {
					curDeStep--;
					clearDecisions();
					makeDecisions();
					changeItem();
					FlxG.sound.play(Paths.sound('extras/selection-cancel','preload'));
				}
				else {
					if (chosen[curDecision[curDeStep]][1] != '') {
						curDeStep++;
						curDecision[curDeStep] = 0;
						clearDecisions();
						makeDecisions();
						changeItem();
						FlxG.sound.play(Paths.sound('extras/title-decision','preload'));
					}
					else {
						finished = true;
						confirm(str);
						if (finished) FlxG.sound.play(Paths.sound('extras/selection-confirm','preload'));
					}
				}
			}
		}
	}
	
	function confirm(chosen:String) {
		switch(chosen) {
			case "Exit": {
				FlxG.switchState(new ExitState());
				FlxTween.tween(FlxG.sound.music,{volume : 0},1.5);
			}
			//case "Options": FlxG.switchState(new OptionsMenu());
			case "Play.Easy" | "Play.Normal" | "Play.Hard": {
				PlayState.storyPlaylist = songs;
				PlayState.isStoryMode = true;
				
				PlayState.storyDifficulty = 1;
				if (chosen == "Play.Easy") PlayState.storyDifficulty = 0;
				if (chosen == "Play.Hard") PlayState.storyDifficulty = 2;
				FlxG.save.data.niko_curprogress = [0,PlayState.storyDifficulty];
				FlxG.save.flush();

				// adjusting the song name to be compatible
				var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");

				var poop:String = Highscore.formatSong(songFormat, PlayState.storyDifficulty);
				PlayState.sicks = 0;
				PlayState.bads = 0;
				PlayState.shits = 0;
				PlayState.goods = 0;
				PlayState.campaignMisses = 0;
				PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
				PlayState.storyWeek = 0;
				PlayState.campaignScore = 0;
				LoadingState.loadAndSwitchState(new PlayState(),false);
				FlxTween.tween(FlxG.sound.music,{volume : 0},1.5);
			}
			case "Continue": {
				PlayState.storyPlaylist = songs;
				if (FlxG.save.data.niko_curprogress[0] > 0) {
					for (i in 0...FlxG.save.data.niko_curprogress[0]) PlayState.storyPlaylist.remove(PlayState.storyPlaylist[0]);
				}
				PlayState.isStoryMode = true;
				
				PlayState.storyDifficulty = FlxG.save.data.niko_curprogress[1];

				// adjusting the song name to be compatible
				var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");

				var poop:String = Highscore.formatSong(songFormat, PlayState.storyDifficulty);
				PlayState.sicks = 0;
				PlayState.bads = 0;
				PlayState.shits = 0;
				PlayState.goods = 0;
				PlayState.campaignMisses = 0;
				PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
				PlayState.storyWeek = 0;
				PlayState.campaignScore = 0;
				LoadingState.loadAndSwitchState(new PlayState(), true);
			}
			case "Credits" | "Options": {
				var state = (chosen == "Credits") ? new CCreditsState() : new COptionsState();
				state.closeCallback = function() {
					if (chosen == "Options" && state.gotokeybind) {
						state.destroy();
						new FlxTimer().start(.1,function(tmr:FlxTimer) {
							var astate = new KeyBindMenu();
							astate.closeCallback = function() {
								finished = true;
								confirm(chosen);
								astate.clear();
								astate.kill();
								astate.destroy();
							};
							openSubState(astate);
						});
					} else {state.destroy();finished = false;}
				};
				openSubState(state);
			}
			default: finished = false;
		}
	}
	
	/*function getCurrentDec() {
		var chosen = decisions;
		if (curDeStep > 0) {
			for (i in 0...curDeStep) chosen = chosen[curDecision[i]];
		}
		return chosen;
	}*/
	
	function makeDecision(str) {
		var text:FlxText = new FlxText(75,(FlxG.height * .725) + (30 * items.length), FlxG.width, str, 28);
		text.font = 'VCR OSD Mono';
		text.color = 0xFFFFFFFF;
		text.ID = items.length;
		text.scrollFactor.set(0,0);
		text.antialiasing = FlxG.save.data.antialiasing;
		items.add(text);
		//return text;
	}
	
	function clearDecisions() {
		items.forEach(function(item:FlxSprite) {
			items.remove(item);
			item.kill();
			item.destroy();
		});
		items.clear();
	}
	
	function makeDecisions() {
		var chosen = decisions;
		var str = '';
		if (curDeStep > 0) {
			for (i in 0...curDeStep) {
				if (i+1 == curDeStep) {str = str + chosen[curDecision[i]][0];} else str = str + chosen[curDecision[i]][0] + " > ";
				chosen = chosen[curDecision[i]][1];
			}
		}
		for (i in chosen) {
			makeDecision(i[0]);
		}
		if (curDeStep > 0) {itemtitle.text = str;} else itemtitle.text = 'Main';
	}
	
	function changeItem(move:Int = 0) {
		if (move != 0) FlxG.sound.play(Paths.sound('extras/selection-move','preload'));
		curDecision[curDeStep] += move;
		if (curDecision[curDeStep] >= items.length)
			curDecision[curDeStep] = 0;
		if (curDecision[curDeStep] < 0)
			curDecision[curDeStep] = items.length - 1;
			
		items.forEachAlive(function(item:FlxSprite) {
			if (item.ID == curDecision[curDeStep]) {
				item.alpha = 1;
				item.setPosition(90,item.y);
				decisionPoint.setPosition(decisionPoint.x,item.getGraphicMidpoint().y - (decisionPoint.height / 2) + 2);
				decisionPoint.updateHitbox();
			} else {
				item.alpha = .9;
				item.setPosition(75,item.y);
			}

			item.updateHitbox();
		});
	}
}

class CustomSubMenu extends FlxSubState {
	var title:String = '';
	
	public var gotokeybind:Bool = false;
	public var decisions:Array<Dynamic>;
	var items:FlxTypedGroup<FlxSprite>;
	var items2:FlxTypedGroup<FlxSprite>;
	var decisionPoint:FlxSprite;
	var curDecision:Array<Int> = [0,0,0,0];
	var curDeStep:Int = 0;

	var bg:FlxSprite;
	var isbg:Bool = false;
	var stitle:FlxText;
	
	public function init(t:String='',d:Array<Dynamic>) {
		title = t;
		decisions = d;
		
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		isbg = true;
	}
	
	public static var finished:Bool = false;
	public static var starting:Bool = true;
	public var cursorSound:Bool = false;
	
	override public function create() {
		gotokeybind = false;
		finished = false;
		starting = true;
		
		stitle = new FlxText(FlxG.width * .06,FlxG.height * .07,title, 64);
		stitle.font = 'Terminus (TTF) Bold';
		stitle.alpha = 0;
		stitle.color = 0xFFFFFFFF;
		stitle.scrollFactor.set();
		stitle.antialiasing = FlxG.save.data.antialiasing;
		
		items = new FlxTypedGroup<FlxSprite>();
		add(items);
		
		items2 = new FlxTypedGroup<FlxSprite>();
		add(items2);
		
		add(stitle);
		super.create();
		
		makeDecisions();
		changeItem();
		
		if (isbg) FlxTween.tween(bg,{alpha : .5},.5);
		FlxTween.tween(stitle,{alpha : 1},.5);
		items.forEach(function(item:FlxSprite) {
			var alp = item.alpha;
			item.alpha = 0;
			FlxTween.tween(item,{alpha : alp},.5);
		});
		items2.forEach(function(item:FlxSprite) {
			var alp = item.alpha;
			item.alpha = 0;
			FlxTween.tween(item,{alpha : alp},.5);
		});
		new FlxTimer().start(.51,function(tmr:FlxTimer) {
			starting = false;
		});
	}
	
	public function sclose() {
		if (isbg) FlxTween.tween(bg,{alpha : 0},.5);
		finished = true;
		FlxTween.tween(stitle,{alpha : 0},.5);
		FlxG.sound.play(Paths.sound('extras/selection-cancel','preload'));
		new FlxTimer().start(.03,function(tmr:FlxTimer) {
			items.forEach(function(item:FlxSprite) {
				FlxTween.tween(item,{alpha : 0},.5);
			});
			items2.forEach(function(item:FlxSprite) {
				FlxTween.tween(item,{alpha : 0},.5);
			});
			new FlxTimer().start(.51,function(tmr:FlxTimer) {
				clearDecisions();
				clear();
				kill();
				close();
			});
		});
	}
	
	var runtime:Float = -1000000;
	var idklol:Array<Float> = [-1000000,-1000000,-1000000,-1000000];
	var idklol2:Array<Bool> = [false,false,false,false];
	override function update(elapsed:Float) {
		super.update(elapsed);
		
		runtime += elapsed;
		
		if (!finished && !starting) {
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
			var justright:Bool = FlxG.keys.pressed.RIGHT;
			var justleft:Bool = FlxG.keys.pressed.LEFT;
			if (gamepad != null) {
				if (gamepad.pressed.DPAD_UP && runtime > idklol[2]) {
					idklol[2] = runtime+.07;
					if (!idklol2[2]) idklol[2] += .43;
					changeItem(-1);
				}
				if (!gamepad.pressed.DPAD_UP) idklol[2] = runtime;
				if (gamepad.pressed.DPAD_DOWN && runtime > idklol[1]) {
					idklol[1] = runtime+.07;
					if (!idklol2[1]) idklol[1] += .43;
					changeItem(1);
				}
				if (!gamepad.pressed.DPAD_DOWN) idklol[1] = runtime;
				justright = (!justright) ? (gamepad.pressed.DPAD_RIGHT) : justright;
				justleft = (!justleft) ? (gamepad.pressed.DPAD_LEFT) : justleft;
			}
			else {
				if (FlxG.keys.pressed.UP && runtime > idklol[2]) {
					idklol[2] = runtime+.07;
					if (!idklol2[2]) idklol[2] += .43;
					changeItem(-1);
				}
				if (!FlxG.keys.pressed.UP) idklol[2] = runtime;
				if (FlxG.keys.pressed.DOWN && runtime > idklol[1]) {
					idklol[1] = runtime+.07;
					if (!idklol2[1]) idklol[1] += .43;
					changeItem(1);
				}
				if (!FlxG.keys.pressed.DOWN) idklol[1] = runtime;
				
				idklol2[1] = FlxG.keys.pressed.DOWN;
				idklol2[2] = FlxG.keys.pressed.UP;
			}
			var idklol3 = idklol[3];
			var idklol0 = idklol[0];
			if (justright && runtime > idklol[3]) {
				idklol[3] = runtime+.07;
				if (!idklol2[3]) idklol[3] += .43;
			}
			if (!justright) idklol[3] = runtime;
			if (justleft && runtime > idklol[0]) {
				idklol[0] = runtime+.07;
				if (!idklol2[0]) idklol[0] += .43;
			}
			if (!justleft) idklol[0] = runtime;
			idklol2[3] = justright;
			idklol2[0] = justleft;
			
			justright = justright && runtime > idklol3;
			justleft = justleft && runtime > idklol0;
			
			if (PlayerSettings.player1.controls.BACK) {
				if (curDeStep == 0) {sclose();} else {
					curDecision[curDeStep] = -1;
					changeItem();
				}
			}
			
			if (PlayerSettings.player1.controls.ACCEPT || (justright || justleft) || (PlayerSettings.player1.controls.BACK && curDeStep > 0)) {
				var chosen = decisions;
				var str = '';
				if (curDeStep > 0) {
					for (i in 0...curDeStep) {
						str = str + chosen[curDecision[i]][0] + ".";
						chosen = chosen[curDecision[i]][1];
					}
				}
				str = str + chosen[curDecision[curDeStep]][0];
				
				if (chosen[curDecision[curDeStep]][3] != null) {
					if (justright) {
						cursorSound = true;
						right(str);
						updateDecisions();
						if (cursorSound) FlxG.sound.play(Paths.sound('extras/title-cursor','preload'),.5);
					}
					else {
						if (justleft) {
							cursorSound = true;
							left(str);
							updateDecisions();
							if (cursorSound) FlxG.sound.play(Paths.sound('extras/title-cursor','preload'),.5);
						}
					}
				}
					
				if (PlayerSettings.player1.controls.ACCEPT || (PlayerSettings.player1.controls.BACK && curDeStep > 0)) {
					if (chosen[curDecision[curDeStep]][0] == "Previous") {
						curDeStep--;
						clearDecisions();
						makeDecisions();
						changeItem();
						FlxG.sound.play(Paths.sound('extras/selection-cancel','preload'));
					}
					else {
						if (chosen[curDecision[curDeStep]][1] != '') {
							curDeStep++;
							curDecision[curDeStep] = 0;
							clearDecisions();
							makeDecisions();
							changeItem();
							FlxG.sound.play(Paths.sound('extras/title-decision','preload'));
						}
						else {
							cursorSound = true;
							confirm(str);
							updateDecisions();
							if (cursorSound) FlxG.sound.play(Paths.sound('extras/selection-confirm','preload'));
						}
					}
				}
			}
		}
	}
	
	public function confirm(chosen:String) {}
	public function left(chosen:String) {}
	public function right(chosen:String) {}
	
	function makeDecision(str:String,str2:String,bold:Bool,?italic:Bool = false) {
		var text:FlxText = new FlxText(FlxG.width * .1,(FlxG.height * .22) + (30 * items.length), FlxG.width, str, 28);
		text.font = 'VCR OSD Mono';
		text.color = 0xFFFFFFFF;
		text.ID = items.length;
		text.antialiasing = FlxG.save.data.antialiasing;
		if (bold) {
			text.borderSize = .35;
			text.borderColor = 0xFFFFFFFF;
			text.borderStyle = OUTLINE;
		}
		#if flash
		text.italic = italic;
		#else
		text.font = (italic) ? 'HigashiOme Gothic regular' : text.font;
		#end
		text.scrollFactor.set(0,0);
		items.add(text);
		
		var text:FlxText = new FlxText(FlxG.width * .45,(FlxG.height * .22) + (30 * items2.length), FlxG.width, str2, 28);
		text.font = 'VCR OSD Mono';
		text.color = 0xFFFFFFFF;
		text.ID = items2.length;
		text.antialiasing = FlxG.save.data.antialiasing;
		if (bold) {
			text.borderSize = .35;
			text.borderColor = 0xFFFFFFFF;
			text.borderStyle = OUTLINE;
		}
		#if flash
		text.italic = italic;
		#else
		text.font = (italic) ? 'HigashiOme Gothic regular' : text.font;
		#end
		text.scrollFactor.set(0,0);
		items2.add(text);
		//return text;
	}
	
	function clearDecisions() {
		items.forEach(function(item:FlxSprite) {
			items.remove(item);
			item.kill();
			item.destroy();
		});
		items.clear();
		items2.forEach(function(item:FlxSprite) {
			items2.remove(item);
			item.kill();
			item.destroy();
		});
		items2.clear();
	}
	
	function makeDecisions() {
		var chosen = decisions;
		var str = title + ' > ';
		if (curDeStep > 0) {
			for (i in 0...curDeStep) {
				var v = (chosen[curDecision[i]][2] == null) ? chosen[curDecision[i]][0] : chosen[curDecision[i]][2];
				if (i+1 == curDeStep) {str = str + v;} else str = str + v + " > ";
				chosen = chosen[curDecision[i]][1];
			}
		}
		for (i in chosen) {
			makeDecision((i[2] == null) ? i[0] : i[2],(i[3] == null) ? '' : Std.string(i[3]()),(i[1] != ''),(i[4] != null && i[4] == true) ? true : false);
		}
		if (curDeStep > 0) {stitle.text = str;} else stitle.text = title;
	}
	
	function updateDecisions() {
		clearDecisions();
		makeDecisions();
		changeItem();
	}
	
	function changeItem(move:Int = 0) {
		if (move != 0) FlxG.sound.play(Paths.sound('extras/selection-move','preload'));
		curDecision[curDeStep] += move;
		if (curDecision[curDeStep] >= items.length)
			curDecision[curDeStep] = 0;
		if (curDecision[curDeStep] < 0)
			curDecision[curDeStep] = items.length - 1;
			
		items.forEachAlive(function(item:FlxSprite) {
			if (item.ID == curDecision[curDeStep]) {
				item.alpha = 1;
				item.setPosition(FlxG.width * .11,item.y);
			} else {
				item.alpha = .9;
				item.setPosition(FlxG.width * .1,item.y);
			}

			item.updateHitbox();
		});
		items2.forEachAlive(function(item:FlxSprite) {
			if (item.ID == curDecision[curDeStep]) {
				item.alpha = 1;
				item.setPosition(FlxG.width * .46,item.y);
			} else {
				item.alpha = .9;
				item.setPosition(FlxG.width * .45,item.y);
			}

			item.updateHitbox();
		});
	}
	
	public function fancyOpenURL(schmancy:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}
}

class COptionsState extends CustomSubMenu {
	var vers:FlxText;
	override public function create() {
		super.init(
			"Options",[
				[
					'gp',[
						["kb",'',"Keybinds"],
						["acd",'',"Accuracy Mode",function() {
							return (FlxG.save.data.accuracyMod == 0 ? "Accurate" : "Complex");
						}],
						["ds",'',"Downscroll",function() {
							return FlxG.save.data.downscroll;
						}],
						["fps",'',"FPS Cap",function() {
							return FlxG.save.data.fpsCap;
						}],
						["gt",'',"Ghost Tap",function() {
							return FlxG.save.data.ghost;
						}],
						["sf",'',"Safe Frames",function() {
							return Conductor.safeFrames;
						}],
						["ss",'',"Scroll Speed",function() {
							return FlxG.save.data.scrollSpeed;
						}],
						['Previous','']
					],'Gameplay'
				],
				[
					'ap',[
						["ac",'',"Accuracy Display",function() {
							return FlxG.save.data.accuracyDisplay;
						}],
						["cz",'',"Camera Zoom",function() {
							return FlxG.save.data.camzoom;
						}],
						["nps",'',"NPS Display",function() {
							return FlxG.save.data.npsDisplay;
						}],
						["fps",'',"FPS Counter",function() {
							return FlxG.save.data.fps;
						}],
						["rfps",'',"Rainbow FPS",function() {
							return FlxG.save.data.fpsRain;
						}],
						['Previous','']
					],'Appearance'
				],
				[
					'ms',[
						['Previous','']
					],'Misc'
				],
			]
		);
		
		vers = new FlxText(2,FlxG.height-26, FlxG.width,MainMenuState.gameVer + " | KE : " + MainMenuState.kadeEngineVer + " | Mod : " + MainMenuState.modVer, 24);
		vers.font = 'VCR OSD Mono';
		vers.alpha = 0;
		vers.color = 0xFFFFFFFF;
		vers.scrollFactor.set(0,0);
		vers.antialiasing = FlxG.save.data.antialiasing;
		
		add(vers);
		
		FlxTween.tween(vers,{alpha : .5},.5);
		super.create();
	}
	
	override function confirm(chosen:String) {
		switch(chosen) {
			case 'gp.ds': FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
			case 'gp.gt': FlxG.save.data.ghost = !FlxG.save.data.ghost;
			case 'gp.kb': {
				gotokeybind = true;
				FlxTween.tween(vers,{alpha : 0},.5);
				super.sclose();
			}
			case 'gp.acd': FlxG.save.data.accuracyMod = FlxG.save.data.accuracyMod == 1 ? 0 : 1;
			
			case 'ap.ac': FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;
			case 'ap.cz': FlxG.save.data.camzoom = !FlxG.save.data.camzoom;
			case 'ap.nps': FlxG.save.data.npsDisplay = !FlxG.save.data.npsDisplay;
			case 'ap.fps': {
				FlxG.save.data.fps = !FlxG.save.data.fps;
				(cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
			}
			case 'ap.rfps': {
				FlxG.save.data.fpsRain = !FlxG.save.data.fpsRain;
				(cast (Lib.current.getChildAt(0), Main)).changeFPSColor(FlxColor.WHITE);
			}
			
			default: cursorSound = false;
		}
		super.confirm(chosen);
	}
	
	override function right(chosen:String) {
		switch(chosen) {
			case 'gp.fps': {
				if (FlxG.save.data.fpsCap < 60) FlxG.save.data.fpsCap = 50;
				FlxG.save.data.fpsCap += 10;
				if (FlxG.save.data.fpsCap > 290) FlxG.save.data.fpsCap = 290;
				(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
			}
			case 'gp.sf': {
				if (Conductor.safeFrames < 20) {
					Conductor.safeFrames += 1;
					FlxG.save.data.frames = Conductor.safeFrames;

					Conductor.recalculateTimings();
				}
			}
			case 'gp.ss': {
				if (FlxG.save.data.scrollSpeed <= 4) FlxG.save.data.scrollSpeed += .1;
			}
			default: cursorSound = false;
		}
		super.right(chosen);
	}
	
	override function left(chosen:String) {
		switch(chosen) {
			case 'gp.fps': {
				FlxG.save.data.fpsCap -= 10;
				if (FlxG.save.data.fpsCap < 60) FlxG.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
				(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
			}
			case 'gp.sf': {
				if (Conductor.safeFrames > 1) {
					Conductor.safeFrames -= 1;
					FlxG.save.data.frames = Conductor.safeFrames;

					Conductor.recalculateTimings();
				}
			}
			case 'gp.ss': {
				if (FlxG.save.data.scrollSpeed > 1) FlxG.save.data.scrollSpeed -= .1;
			}
			default: cursorSound = false;
		}
		super.left(chosen);
	}
	
	override function sclose() {
		FlxTween.tween(vers,{alpha : 0},.5);
		FlxG.save.flush();
		super.sclose();
	}
}

// PLEASE DO NOT CHANGE THE CREDITS AND AUTHORS ;W;
class CCreditsState extends CustomSubMenu {
	override public function create() {
		super.init(
			"Credits",[
				[
					'Oneshot',[
						['ev','','Eliza Velasquez - Programmer, Scenario',null,true],
						['nm','','Nightmargin - Art, Music, Character Design',null,true],
						['gi','','GIRakaCheezer - Debugging, Programmer',null,true],
						['gs','','The Game',null,true],
						//['gii','','The Game - Itch.io',null,true],
						['p','','The Page',null,true],
						['Previous','']
					]
				],
				[
					"fnf",[
						['nj','','NinjaMuffin99 - Programmer',null,true],
						['pa','','PhantomArcade3k - Artist',null,true],
						['e8','','evilsk8r - Artist',null,true],
						['B)','','KawaiiSprite - SWAG MUSIC',null,true],
						//['gii','','The Game - Itch.io',null,true],
						['gng','','The Game',null,true],
						['mh','','FNF MERCH!!',null,true],
						['Previous','']
					],"Friday Night Funkin'"
				],
				[
					"ke",[
						['kd','','KadeDeveloper - Maintaner, Programmer',null,true],
						['tc','','The Contributors',null,true],
						['p','','The Page',null,true],
						['Previous','']
					],"Kade Engine"
				],
				[
					'mod',[
						['s5','','SMC5 - Music, Author, Director',null,true],
						['r','','Raltyro - Programmer, Charter, Additional Arts',null,true],
						['g','','Gio - Artist',null,true],
						['p','','The Page',null,true],
						['Previous','']
					],'Vs Niko Mod'
				]
			]
		);
		
		super.create();
	}
	
	override function confirm(chosen:String) {
		switch(chosen) {
			case "Oneshot.gii": fancyOpenURL("https://futurecat.itch.io/oneshot");
			case "Oneshot.gs": fancyOpenURL("https://store.steampowered.com/app/420530/OneShot");
			case "Oneshot.ev": fancyOpenURL("https://twitter.com/elizagamedev");
			case "Oneshot.nm": fancyOpenURL("https://twitter.com/NightMargin");
			case "Oneshot.gi": fancyOpenURL("https://twitter.com/girakacheezer");
			case "Oneshot.p": fancyOpenURL("https://www.oneshot-game.com");
			
			case "fnf.gii": fancyOpenURL("https://ninja-muffin24.itch.io/funkin");
			case "fnf.gng": fancyOpenURL("https://www.newgrounds.com/portal/view/770371");
			case "fnf.B)": fancyOpenURL("https://twitter.com/kawaisprite");
			case "fnf.pa": fancyOpenURL("https://twitter.com/PhantomArcade3k");
			case "fnf.e8": fancyOpenURL("https://twitter.com/evilsk8r");
			case "fnf.nj": fancyOpenURL("https://twitter.com/ninja_muffin99");
			case "fnf.mh": fancyOpenURL("https://sharkrobot.com/collections/newgrounds");
			
			case "ke.kd": fancyOpenURL("https://twitter.com/KadeDeveloper");
			case "ke.tc": fancyOpenURL("https://github.com/KadeDev/Kade-Engine/graphs/contributors");
			case "ke.p": fancyOpenURL("https://github.com/KadeDev/Kade-Engine");
			
			case "mod.s5": fancyOpenURL("https://gamebanana.com/members/1886575");
			case "mod.r": fancyOpenURL("https://gamebanana.com/members/1777465");
			case "mod.g": fancyOpenURL("https://gamebanana.com/members/1957199");
			case "mod.p": fancyOpenURL("https://gamebanana.com/wips/58024");
		}
		super.confirm(chosen);
	}
}