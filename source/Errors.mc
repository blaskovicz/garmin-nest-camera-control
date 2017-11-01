// custom errors for instanceof checking in catch() clause
class BaseError {
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

class InvalidArgumentEror extends BaseError {}