import lime.app.Application;
import haxe.Exception;
import lime.system.System;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

typedef Marshal_var = {
	var content:Dynamic;
	var skip:Int;
}

class Oneshot {
	// https://github.com/elizagamedev/mkxp-oneshot
	// Modified MKXP for Oneshot
	
	public static var hasoneshot:Bool = false;
	public static var perma_flags:Array<Bool> = [];
	public static var perma_vars:Array<Dynamic> = [];
	public static var playername:String = 'Player';
	public static var savePath:String = '';
	
	public static function init() {
		#if sys
			// I still don't know if this is the correct variable in unix devices, i only have windows in my entire life ;w;
			// physfs/blob/master/src/physfs_platform_unix.c __PHYSFS_platformCalcPrefDir
			var append:String = '/';
			if (Sys.systemName() == 'Windows')
				append = Sys.getEnv("APPDATA");
			else if (Sys.systemName() == 'Mac' || Sys.systemName() == 'Linux' || Sys.systemName() == 'BSD') { // Unix Devices
				append = Sys.getEnv("XDG_DATA_HOME");
				// We goin using XDG if it's not linux, if both of env is null then let's ignore, pls don't call me racist :(
				if (append == null) {
					append = Sys.getEnv("HOME");
					if (append != null) {append = append + '/.local/share';} else {
						append = Sys.getEnv("PATH");
						if (append != null) {
							append = append + '/Library/Application Support';
							if (!FileSystem.exists(append)) append = Sys.getEnv("PATH");
						}
					}
				}
			}
			if (append == null) {trace('NO APPEND FOUND');trace(Sys.systemName());trace(append);} else {
				trace(append);
				if (FileSystem.exists(append + "/Oneshot") && FileSystem.isDirectory(append + "/Oneshot")) savePath = append + "/Oneshot";
			}
			
			if (savePath != '' && FileSystem.exists(savePath + "/p-settings.dat")) {
				hasoneshot = true;
			}
		#end
	}
	
	public static function load_perma_flags() {
		trace(savePath);
		if (hasoneshot) {
			try {
				read_perma_flags(savePath + "/p-settings.dat");
			}
			catch(w:Exception) {
				#if sys
					trace('oops: ' + w.message);
					if (FileSystem.exists(savePath + "/save_backups")) {
						Application.current.window.alert('p-settings.dat corrupt. Attempting to load backup.','');
						for (i in 1...6) {
							try {
								read_perma_flags(savePath + "/save_backups/p-settings" + Std.string(i) + ".bk");
								break;
							}
							catch(w:Exception) {
								trace('oops: ' + w.message);
								if (i == 5) {
									Application.current.window.alert('All p-settings backups corrupt! Shutting down. \nConsidering you have to reload your game "Oneshot" in order to continue.','');
									System.exit(0);
									break;
								} else Application.current.window.alert('p-settings' + Std.string(i) + '.bk corrupt. Attempting to load backup.','');
							}
						}
					}
					else {
						Application.current.window.alert('p-settings corrupt! Shutting down. \nConsidering you have to reload your game "Oneshot" in order to continue.','');
						System.exit(0);
					}
				#end
			}
		}
		else {
			playername = 'Player';
			for (i in 0...24) {perma_flags[i] = false;perma_vars[i] = 0;}
		}
		trace(playername);
	}
	
	static function read_perma_flags(filename:String) {
		#if sys
			if (!FileSystem.exists(filename)) throw(filename + " - File doesn't exists.");
			var content = marshal_read_file(filename);
			trace(content);
			for (i in 0...content.length) {
				switch(i) {
					case 0: perma_flags = content[i];
					case 1: perma_vars = content[i];
					case 2: playername = Std.string(content[i]);
				}
			}
		#else
			playername = 'Player';
			for (i in 0...24) {perma_flags[i] = false;perma_vars[i] = 0;}
		#end
		return true;
	}
	
	// STUPID RUBY/MARSHAL MIMIC CODES LOL (help me)
	static function marshal_type_step(str:String,simple:Bool):Null<Marshal_var> {
		//trace(str);
		switch(str.charCodeAt(0)) {
			case 70:
				return {content : false,skip : 0};
			case 73:
				if (str.charCodeAt(1) == 34) {
					if (str.substring(str.charCodeAt(2)-2,str.charCodeAt(2)+3) != ":ET") throw("Uncorrect length");
					return {content : str.substring(3,str.charCodeAt(2)-2),skip : str.charCodeAt(2)+4};
				}
				throw("Unrecognized type");
			case 84:
				return {content : true,skip : 0};
			case 91:
				return marshal_type_array(str,simple);
			case 105:
				return {content : str.charCodeAt(1),skip : 1};
			default:
				throw("Unrecognized type");
		}
	}
	
	static function marshal_type_array(str:String,simple:Bool):Marshal_var {
		var content:Array<Dynamic> = [];
		var skip:Int = 0;
		var step:Int = 0;
		var length:Int = str.charCodeAt(1) - 6;
		for (i in 2...str.length) {
			if (step > length) break;
			if (skip > 0) {skip = skip - 1;continue;}
			if ((str.charAt(i) + str.charAt(i+1)) == "") throw("Uncorrect length");
			//trace(str.charAt(i));
			//trace(step);
			//trace(length);
			if (simple) {
				var ins = marshal_type_step(str.substring(i,str.length),simple);
				skip += ins.skip;
				content.push(ins.content);
			}
			step += 1;
		}
		return {content : content,skip : step};
	}
	
	static function marshal_type_main(str:String,simple:Bool):Array<Dynamic> {
		var content:Array<Dynamic> = [];
		var skip = 0;
		for (i in 0...str.length) {
			if (skip > 0) {skip = skip - 1;continue;}
			if (simple) {
				if ((str.charAt(i) + str.charAt(i+1)) == "") {
					var ins = marshal_type_step(str.substring(i+2,str.length),simple);
					skip += ins.skip;//+1;
					content.push(ins.content);
				}
			}
		}
		return content;
	}
	
	static function marshal_read_file(file:String):Array<Dynamic> {
		#if sys
			return marshal_type_main(File.getContent(file),true);
		#end
	}
}
