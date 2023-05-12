package system;

import flixel.FlxG;

class ModLoader
{
    public static var mod_dirs:Array<String> = [];

	public static function reloadMods()
	{
		#if polymod
		mod_dirs = [];

		for(meta in polymod.Polymod.scan("mods"))
		{
			mod_dirs.push(meta.id);
		}

		if(!FlxG.save.data.mods)
		    mod_dirs = [];

		if (FlxG.save.data.mods == null)
			FlxG.save.data.mods = true;

        polymod.Polymod.init({
			modRoot: "mods",
			dirs: mod_dirs,
			framework: OPENFL,
			errorCallback: function(error:polymod.Polymod.PolymodError)
			{
				#if debug
				trace(error.message);
				#end
			},
			frameworkParams: {
				assetLibraryPaths: [
					"songs" => "songs",
					"shared" => "shared",
                    "tutorial" => "tutorial",
					"week1" => "week1",
					"week2" => "week2",
					"week3" => "week3",
					"week4" => "week4",
					"week5" => "week5",
					"week6" => "week6"
				]
			}
		});
		#end
	}
}
