class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.isTimeout = false,
    this.isOfflineEligible = false,
  });

  final String message;
  final int? statusCode;
  final bool isTimeout;
  final bool isOfflineEligible;

  @override
  String toString() => message;
}
