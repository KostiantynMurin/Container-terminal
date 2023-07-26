public virtual class IntegrationError {
	protected String errorMessage;

	public IntegrationError() {
	}

	public IntegrationError(Exception ex) {
		this.errorMessage = 'EXCEPTION: ' + ex.getMessage() + '\n' + ex.getStackTraceString();
	}

	public IntegrationError(String error) {
		this.errorMessage = error;
	}

	public String getMessage() {
		return errorMessage;
	}

	public class IntegrationErrorException extends Exception {
	}
}