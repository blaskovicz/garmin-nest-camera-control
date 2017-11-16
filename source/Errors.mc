using Toybox.Lang;

class BaseError extends Lang.Exception {
	// custom errors for instanceof checking in catch() clause
	protected var cause;
	function initialize(cause) {
		self.cause = cause;
		Exception.initialize();
	}
	function getErrorMessage() {
		return self.cause;
	}
}

class InvalidArgumentError extends BaseError { function initialize(cause){ BaseError.initialize(cause); } }