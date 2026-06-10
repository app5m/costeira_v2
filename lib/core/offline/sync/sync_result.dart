class SyncResult {
  const SyncResult({
    required this.totalItems,
    required this.successCount,
    required this.errorCount,
    required this.noConnection,
    required this.isEmpty,
  });

  factory SyncResult.empty() {
    return const SyncResult(
      totalItems: 0,
      successCount: 0,
      errorCount: 0,
      noConnection: false,
      isEmpty: true,
    );
  }

  factory SyncResult.noConnection({int totalItems = 0}) {
    return SyncResult(
      totalItems: totalItems,
      successCount: 0,
      errorCount: 0,
      noConnection: true,
      isEmpty: totalItems == 0,
    );
  }

  final int totalItems;
  final int successCount;
  final int errorCount;
  final bool noConnection;
  final bool isEmpty;
}
