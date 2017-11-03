using Toybox.Lang;

class BaseError extends Lang.Exception {
	// custom errors for instanceof checking in catch() clause
	private var cause;
	function initialize(cause) {
		Exception.initialize();
		self.cause = cause;
	}
	function getCause() {
		return self.cause;
	}
	function toString() {
		return self.getCause();
	}
}

class InvalidArgumentError extends BaseError { function initialize(cause){ BaseError.initialize(cause); } }