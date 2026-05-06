import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService extends GetxService {
  late GetStorage _box;

  Future<StorageService> init() async {
    debugPrint('StorageService init called');
    _box = GetStorage();
    return this;
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
}
