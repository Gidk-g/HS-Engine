package system;

import openfl.Assets;
import openfl.media.Sound;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

class ModPaths
{
    inline static public function modImage(key:String)
    {
        #if sys
        for (dir in FileSystem.readDirectory(Sys.getCwd() + 'mods'))
        {
            if (FileSystem.exists(Sys.getCwd() + 'mods/' + dir + '/$key'))
            {
                var file:FlxGraphic;
                if (!Assets.cache.hasBitmapData(Sys.getCwd() + 'mods/' + dir + '/$key'))
                    file = FlxGraphic.fromBitmapData(BitmapData.fromFile(Sys.getCwd() + 'mods/' + dir + '/$key'), false, Sys.getCwd() + 'mods/' + dir + '/$key', true)
                else
                    file = FlxGraphic.fromBitmapData(Assets.cache.getBitmapData(Sys.getCwd() + 'mods/' + dir + '/$key'), false, '', false);
                return file;
            }
        }
        return null;
        #end
    }

    inline static public function modSound(key:String)
    {
        #if sys
        for (dir in FileSystem.readDirectory(Sys.getCwd() + 'mods'))
        {
            if (FileSystem.exists(Sys.getCwd() + 'mods/' + dir + '/$key'))
            {
                return Sound.fromFile(Sys.getCwd() + 'mods/' + dir + '/$key');
            }
        }
        return null;
        #end
    }

    inline static public function modTxt(key:String)
    {
        #if sys
        for (dir in FileSystem.readDirectory(Sys.getCwd() + 'mods'))
        {
            if (FileSystem.exists(Sys.getCwd() + 'mods/' + dir + '/$key'))
            {
			    return File.getContent(Sys.getCwd() + 'mods/' + dir + '/$key');
			}
        }
        return null;
        #end
    }
}