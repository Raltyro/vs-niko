package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
class WarningState extends MusicBeatState {
	var bg:FlxSprite;
	var text:FlxText;
	override public function create() {
		text = new FlxText(2,0, FlxG.width,
			"WARNING
			\nThis mod included surreal experiences that may can go beyond the game window
			\nIt can read your computer username, you can change it on the options.appearance anytime you want
			\nthis is not a horror mod, please proceed with caution
			\nPress ENTER to continue"
		, 24);
		text.alignment = CENTER;
		text.font = 'Terminus (TTF) Bold';
		text.color = 0xFFFFFFFF;
		text.scrollFactor.set();
		text.screenCenter();
		text.antialiasing = FlxG.save.data.antialiasing;
		
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		
		add(bg);
		add(text);
		super.create();
	}
	
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (controls.ACCEPT) FlxG.switchState(new CustomMenu());
	}
}