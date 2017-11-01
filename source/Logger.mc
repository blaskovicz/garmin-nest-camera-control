using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

var l;

// custom singleton logger
class Logger {
	enum {
		LevelDebug = 0,
		LevelInfo = 1,
		LevelWarn = 2,
		LevelError = 3
	}
	
	protected var level = LevelDebug;
	static function getInstance() {
		if (l == null) {
			l = new Logger(null);
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
			Lang.format("[$1$][$2$-$3$-$4$T$5$:$6$:$7$] $8$", [levelString(level), now.year, now.month.format("%02d"), now.day.format("%02d"), now.hour.format("%02d"), now.min.format("%02d"), now.sec.format("%02d"), msg])
		);
	}
	function debugF(msg, args) {
		self.log(LevelDebug, formatMessageAndArgs(msg, args));
	}
	function infoF(msg, args) {
		self.log(LevelInfo, formatMessageAndArgs(msg, args));
	}
	function warnF(msg, args) {
		self.log(LevelWarn, formatMessageAndArgs(msg, args));
	}
	function errorF(msg, args) {
		self.log(LevelError, formatMessageAndArgs(msg, args));
	}
	function fatalF(msg, args) {
		self.log(LevelError, formatMessageAndArgs(msg, args));
		System.exit();
	}
	function debug(msg) {
		self.log(LevelDebug, msg);
	}
	function info(msg) {
		self.log(LevelInfo, msg);
	}
	function warn(msg) {
		self.log(LevelWarn, msg);
	}
	function error(msg) {
		self.log(LevelError, msg);
	}
	function fatal(msg) {
		self.log(LevelError, msg);
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
			case "DEBUG": {
				self.level = LevelDebug;
				break;
			}
			case "INFO": {
				self.level = LevelInfo;
				break;
			}
			case "WARN": {
				self.level = LevelWarn;
				break;
			}
			case "ERROR":
			case "FATAL": {
				self.level = LevelError;
				break;
			}
			default: {
				throw new InvalidArgumentEror(Lang.format("invalid level argument '$1' passed to logger", [level]));
			}			
		}	
	}
	// If I try to make this private, I get - ERROR:stdin:1023: Redefinition of label (code) globals_Logger_initialize
	function initialize(level) {
		if (level == null) {
			return;
		}
		self.setLevel(level);
	}
}