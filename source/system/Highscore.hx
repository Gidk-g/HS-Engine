package system;

import flixel.FlxG;

class Highscore
{
	public static var songScores:Map<String, Int> = new Map<String, Int>();

	public static function saveScore(song:String, score:Int = 0, ?diff:String = "easy"):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
				setScore(daSong, score);
		}
		else
			setScore(daSong, score);
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:String = "easy"):Void
	{
		var daWeek:String = formatSong('week' + week, diff);

		if (songScores.exists(daWeek))
		{
			if (songScores.get(daWeek) < score)
				setScore(daWeek, score);
		}
		else
			setScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:String):String
	{
		var daSong:String = song.toLowerCase();

		if (diff.toLowerCase() != "normal")
			daSong += "-" + diff.toLowerCase();

		return daSong;
	}

	public static function getScore(song:String, diff:String, ?formatted:Bool = false):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore((!formatted ? formatSong(song, diff) : song), 0);

		return songScores.get((!formatted ? formatSong(song, diff) : song));
	}

	public static function getWeekScore(week:Int, diff:String, ?weekName:String = 'week', ?formatted:Bool = false):Int
	{
		if (!songScores.exists(formatSong(weekName + week, diff)))
			setScore(formatSong(weekName + week, diff), 0);

		return songScores.get(formatSong(weekName + week, diff));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
	}
}
