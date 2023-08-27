class FileAlreadyEncryptedException implements Exception {
  FileAlreadyEncryptedException(this.cause);
  final String cause;
}
