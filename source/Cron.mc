using Toybox.Timer;
using Toybox.Lang;

// utility class to wrap Toybox.Timer so that
// we can register and run timers but avoid "too many timers" errors.
var _cron;
static class Cron {
	static const CHECK_LOOP_INTERVAL_MS = 300;
	protected var t;
	protected var jobs;
	
	static function getInstance() {
		if (_cron == null) {
			_cron = new Cron();
		}
		return _cron;
	}

	function initialize() {
		Logger.getInstance().info("ref=cron at=initialize");
		self.jobs = {};
    	self.t = new Timer.Timer();
    	self.t.start(self.method(:checkTimersLoop), CHECK_LOOP_INTERVAL_MS, true);
	}
	
	function register(timerName, everyMs, callback, repeat) {
		if (self.jobs.hasKey(timerName)) {
			throw new InvalidArgumentError(Lang.format("timer already registered with name $1$", [timerName]));
		} else if (everyMs < CHECK_LOOP_INTERVAL_MS) {
			throw new InvalidArgumentError(Lang.format("timer loop must be at least $1$ milliseconds", CHECK_LOOP_INTERVAL_MS));
		} else if (!(callback instanceof Lang.Method)) {
			throw new InvalidArgumentError("callback must be an invokeable method instance");
		}
		
		if (everyMs % CHECK_LOOP_INTERVAL_MS != 0) {
			Logger.getInstance().warnF("Job repeat time $1$ doesn't schedule roundly with cron loop; check config for job=$2$", [everyMs, timerName]);
		}

		self.jobs.put(timerName, {
			:enabled => true,
			:every => everyMs,
			:sinceLast => 0,
			:callback => callback,
			:repeat => repeat
		});
	}
	
	function isRegistered(timerName) {
		return self.jobs.hasKey(timerName);
	}
	
	function isEnabled(timerName) {
		return self.isRegistered(timerName) && self.jobs.get(timerName)[:enabled];
	}
	
	function enable(timerName) {
		if (!self.jobs.hasKey(timerName)) {
			throw new InvalidArgumentError(Lang.format("no such timer found with name $1$", [name]));
		}
		self.jobs[timerName][:enabled] = true;
	}

	function disable(timerName) {
		if (!self.jobs.hasKey(timerName)) {
			throw new InvalidArgumentError(Lang.format("no such timer found with name $1$", [name]));
		}
		self.jobs[timerName][:enabled] = false;
	}
	
	function unregister(timerName) {
		self.jobs.remove(timerName);
	}
	
	function checkTimersLoop() {
		var jobNames = self.jobs.keys();
		for (var i = 0; i < jobNames.size(); i++) {
			var jobName = jobNames[i];
			var job = self.jobs[jobName];
			job[:sinceLast] += CHECK_LOOP_INTERVAL_MS;
			if (!job[:enabled] || job[:sinceLast] < job[:every]) {
				continue;
			}
			
			Logger.getInstance().infoF("ref=cron at=invoke-job-start job-name=$1$ every=$2$ since-last=$3$ repeat=$4$", [jobName, job[:every], job[:sinceLast], job[:repeat]]);
			job[:callback].invoke();
			job[:sinceLast] = 0;
			Logger.getInstance().infoF("ref=cron at=invoke-job-finish job-name=$1$ every=$2$ since-last=$3$ repeat=$4$", [jobName, job[:every], job[:sinceLast], job[:repeat]]);
			
			if (job[:repeat]) {
				continue;
			}
			self.unregister(jobName);
		}
	}
}