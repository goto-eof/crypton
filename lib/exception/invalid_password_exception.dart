class InvalidPasswordException implements Exception {
  InvalidPasswordException(this.cause);
  final String cause;
}
