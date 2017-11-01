// custom singleton logger
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
var l;
class Logger {
	enum {
		LevelDebug = 0,
		LevelInfo = 1,
		LevelWarn = 2,
		LevelError = 3
	}
	
	private var level;
	static function getInstance(level) {
		if (l == null) {
			l = new Logger(level);
		}
		return l;
	}
	static function levelString(level) {
		switch(level) {
			case LevelDebug:
				return "DEBUG";
			case LevelInfo:
				return "INFO";
			case LevelWarn:
				return "WARN";
			case LevelError:
				return "ERROR";
			default:
				return null;
		}
	}
	private static function formatMessageAndArgs(msg, args) {
		if (args == null) {
			return msg;
		}
		if(!(args instanceof Array)) {
			args = [args];
		}
		return Lang.format(msg, args);
	}
	private function log(level, msg) {
		// too verbose for current setting
		if (level < self.level) {
			return;
		}
		var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		System.println(
			Lang.format("[$1][$2-$3-$4T$5:$6:$7] $8", [levelString(level), now.year, now.month, now.day, now.hour, now.min, now.sec, msg])
		);
	}
	function debug(msg, args) {
		self.log(LevelDebug, formatMessageAndArgs(msg, args));
	}
	function info(msg, args) {
		self.log(LevelInfo, formatMessageAndArgs(msg, args));
	}
	function warn(msg, args) {
		self.log(LevelWarn, formatMessageAndArgs(msg, args));
	}
	function error(msg, args) {
		self.log(LevelError, formatMessageAndArgs(msg, args));
	}
	function fatal(msg, args) {
		self.log(LevelError, formatMessageAndArgs(msg, args));
		System.exit();
	}
	function getLevel() {
		return self.level;
	}
	function setLevel(level) {
		// TODO handle enum as arg
		if ( level == null || !(level instanceof String)) {
			throw new InvalidArgumentEror("invalid level argument type passed to logger");
		}
		level = level.toUpper();
		switch(level) {
			case "DEBUG":
				self.level = LevelDebug;
				break;
			case "INFO":
				self.level = LevelInfo;
				break;
			case "WARN":
				self.level = LevelWarn;
				break;
			case "ERROR":
			case "FATAL":
				self.level = LevelError;
				break;
			default:
				throw new InvalidArgumentEror(Lang.format("invalid level argument '$1' passed to logger", [level]));			
		}	
	}
	private function initialize(level) {
		if (level == null) {
			level = "DEBUG";
		}
		self.setLevel(level);
	}
}