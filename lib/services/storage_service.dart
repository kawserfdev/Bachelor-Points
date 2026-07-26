import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService extends GetxService {
  late GetStorage _box;

  void init() {
    debugPrint('StorageService initialized');
    _box = GetStorage();
  }

  void writeData(String key, dynamic value) {
    debugPrint('StorageService writeData called with key: $key');
    _box.write(key, value);
  }

  T? readData<T>(String key) {
    debugPrint('StorageService readData called with key: $key');
    return _box.read<T>(key);
  }

  void removeData(String key) {
    debugPrint('StorageService removeData called with key: $key');
    _box.remove(key);
  }

  /// Wipes all data from local storage. Called on logout to ensure
  /// no stale user-specific data remains on the device.
  Future<void> clearAll() async {
    debugPrint('StorageService clearAll called — erasing all local data');
    await _box.erase();
    debugPrint('StorageService clearAll completed');
  }
}
