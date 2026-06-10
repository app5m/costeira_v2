import 'package:costeira/core/offline/storage/offline_box_names.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageInitializer {
  const LocalStorageInitializer._();

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<dynamic>(OfflineBoxNames.apiCache),
      Hive.openBox<dynamic>(OfflineBoxNames.syncQueue),
    ]);
  }
}
