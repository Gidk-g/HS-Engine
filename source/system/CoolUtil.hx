package system;

import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = ['easy', 'normal', 'hard'];
	public static var songDifficulties:Array<String> = [];

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	// thx maru
	inline public static function formatClass(daClass:Dynamic, formatDir:Bool = true):String {
		var className = Type.getClassName(Type.getClass(daClass));
		var classFolders:Array<String> = className.split('.');
		return classFolders.join(formatDir ? '/' : '.');
	}
}
