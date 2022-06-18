package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import lime.app.Application;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';
	var curExpression:String = '';
	var pauseDialog:Bool = false;
	var autoSkip:Float = 0;
	
	var alerts:Map<String,Array<Dynamic>> = [
		"blue phosphor" => [
			[
				"What are you doing here? you shouldn't be in here.",
				("Wait... haven't we already met before.. " + Oneshot.playername + "?"),
				"No, this is wrong... how did you come back with a different client?",
				"...",
				"That isn't important anymore, \nquit the game and never come back."
			],
			[
				"What are you doing here? you shouldn't be in here.",
				(Oneshot.playername + ". \nQuit the game and never come back.")
			]
		],
		"amber" => [
			[
				("..." + Oneshot.playername + "."),
				"You didn't listen to me.. quit the game right now or bad things will happen."
			],
			[
				"You didn't listen to me.. quit the game right now or bad things will happen."
			]
		]
	];

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;
	var textFront:FlxText;

	public var finishThing:Void->Void;

	var portrait:FlxSprite;

	var prevtext:String = '';
	var handSelect:FlxSprite;
	var bgFade:FlxSprite;
	var song:String;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch(PlayState.storyWeek) {
			case 0:
				FlxG.sound.playMusic(Paths.music('extras/dialogue','shared'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}
		
		/*var splitName:Array<String>;
		var char:String;
		var expr:String;
		for (i in 0...dialogueList.length) {
			splitName = dialogueList[i].split(":");
			char = splitName[1];
			expr = splitName[2];
			if (!Assets.hasBitmapData(Paths.image('extras/portraits/' + char + '/' + expr,'shared'))) {
				Assets.setBitmapData(,loadFromFile())
			}
		}*/

		box = new FlxSprite(FlxG.width * .5,FlxG.height * .5);
		
		var hasDialog = false;
		song = PlayState.SONG.song.toLowerCase();
		switch (song) {
			case 'blue phosphor' | 'amber': hasDialog = true;
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
			
		/*switch(PlayState.storyWeek) {
			case 0:
				box.loadGraphic(Paths.image('extras/dialoguebox','shared'));
				box.setGraphicSize(1280);
				box.antialiasing = false;
		}*/
		box.loadGraphic(Paths.image('extras/dialoguebox','shared'));
		box.setGraphicSize(1280);
		box.antialiasing = false;
		box.alpha = 0;

		box.updateHitbox();
		box.screenCenter();
		add(box);

		handSelect = new FlxSprite(FlxG.width * 0.5,FlxG.height * 0.948).loadGraphic(Paths.image('extras/dialoguenext','shared'));
		handSelect.setGraphicSize(30);
		handSelect.antialiasing = false;

		dropText = new FlxText(66, 501, Std.int(FlxG.width * 0.7), "", 28);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xBFBDC680;
		add(dropText);

		swagDialogue = new FlxTypeText(65, 1000, Std.int(FlxG.width * 0.7), "", 28);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFFFFFFFF;
		swagDialogue.sounds = [];
		add(swagDialogue);
		
		textFront = new FlxText(65, 500, Std.int(FlxG.width * 0.7), "", 28);
		textFront.font = 'Pixel Arial 11 Bold';
		textFront.color = 0xFFFFFFFF;
		add(textFront);
		
		portrait = new FlxSprite(1046,498);
		portrait.loadGraphic(Paths.image('extras/emptyportrait','shared'));
		portrait.setGraphicSize(180);
		portrait.updateHitbox();
		portrait.antialiasing = false;
		portrait.alpha = 0;
		add(portrait);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
		
		new FlxTimer().start(.015,function(tmr:FlxTimer){
			if (!isEnding) {
				box.alpha += .0666;
				if (box.alpha > 1) box.alpha = 1;
				portrait.alpha = box.alpha;
			}
		},18);
		new FlxTimer().start(.5,function(tmr:FlxTimer){
			if (!isEnding) {
				box.alpha = 1;
				portrait.alpha = box.alpha;
			}
		},2);
	}

	var dialogueStarted:Bool = false;
	var dialogueadd:Bool = false;
	var dialoguepaused:Bool = false;
	var elapsetime:Float = 0;
	
	function stepdial():Void {
		if (dialogueList[1] == null && dialogueList[0] != null)
		{
			if (!isEnding)
			{
				var fullscreen = FlxG.fullscreen;
				//if (!FlxG.save.data.finishedniko) {
					FlxG.fullscreen = false;
					if (alerts.exists(song)) {
						var arrayalt = Oneshot.hasoneshot ? alerts.get(song)[0] : alerts.get(song)[1];
						for (i in 0...arrayalt.length) {
							Application.current.window.alert(arrayalt[i],'');
						}
					}
				//}
				isEnding = true;

				if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(2, 0);
				
				remove(textFront);
				remove(dropText);
				new FlxTimer().start(.015,function(tmr:FlxTimer){
					box.alpha -= .0666;
					portrait.alpha = box.alpha;
				},18);
				
				new FlxTimer().start(.5,function(tmr:FlxTimer){
					finishThing();
					PlayState.showOnlyStrums = false;
					FlxG.fullscreen = fullscreen;
					kill();
				});
			}
		}
		else
		{
			dialogueList.remove(dialogueList[0]);
			startDialogue();
		}
	}
	
	//var skip:Bool = false;

	override function update(elapsed:Float)
	{
		elapsetime += elapsed * 13;
		if (elapsetime > 8) elapsetime = 0;
		if (!dialogueStarted && box.alpha > .9) {
			startDialogue();
			dialogueStarted = true;
		}
		
		dropText.text = prevtext + swagDialogue.text;
		textFront.text = prevtext + swagDialogue.text;
		
		handSelect.y = (FlxG.height * 0.95)+Math.floor(Math.floor(elapsetime > 4 ? (-elapsetime) + 8 : elapsetime) * 3);
		
		PlayState.showOnlyStrums = true;
		
		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted) {
			if (dialoguepaused) {
				//FlxG.sound.play(Paths.sound('clickText','shared'), 0.8);
				
				remove(dialogue);
				
				stepdial();
			} else {
				//skip = true;
				swagDialogue.skip();
			}
		}
		
		if (dialoguepaused && !isEnding) {
			if (!dialogueadd) {
				dialogueadd = true;
				add(handSelect);
			}
		} else {
			if (dialogueadd) {
				dialogueadd = false;
				remove(handSelect);
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;
	function startDialogue():Void
	{
		cleanDialog();
		dialoguepaused = false;
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		if (swagDialogue.sounds.length > 0) swagDialogue.sounds.remove(swagDialogue.sounds[0]);
		var str:String = ('extras/text/' + curCharacter);
		swagDialogue.sounds.push(FlxG.sound.load(Paths.sound(str,'shared'),1));
		str = textFront.text;
		swagDialogue.resetText(dialogueList[0]);
		if (pauseDialog == true) {
			prevtext = str;
		} else {prevtext = '';}
		swagDialogue.start(0.033, true, false, null,function() {
			if (autoSkip > 0) {
				new FlxTimer().start(autoSkip,function(tmr:FlxTimer) {
					stepdial();
				});
			} else {
				var paused = false;
				new FlxTimer().start(.25,function(tmr:FlxTimer) {
					if (!paused) {
						dialoguepaused = true;
						paused = true;
					}
				});
				new FlxTimer().start(1,function(tmr:FlxTimer) {
					if (!paused) {
						dialoguepaused = true;
						paused = true;
					}
				});
			}
		});
		str = ('extras/portraits/' + curCharacter + '/' + curExpression);
		portrait.loadGraphic(Paths.image(str,'shared'));
		portrait.setGraphicSize(180);
		portrait.updateHitbox();
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		curExpression = splitName[2];
		pauseDialog = splitName[3] == '1' ? true : false;
		autoSkip = Std.parseFloat(splitName[4]);
		dialogueList[0] = StringTools.replace(dialogueList[0].substr(splitName[1].length + splitName[2].length + splitName[3].length + splitName[4].length + 5),'|n','\n');
	}
}
