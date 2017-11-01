class BaseError {
	// custom errors for instanceof checking in catch() clause
	private var cause;
	function initialize(cause) {
		self.cause = cause;
	}
	function getCause() {
		return self.cause;
	}
	function toString() {
		return self.getCause();
	}
}

class InvalidArgumentEror extends BaseError { function initialize(cause){ BaseError.initialize(cause); } }