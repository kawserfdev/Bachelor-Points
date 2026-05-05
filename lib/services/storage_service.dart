import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  late GetStorage _box;

  Future<StorageService> init() async {
    _box = GetStorage();
    return this;
  }

  void writeData(String key, dynamic value) => _box.write(key, value);
  T? readData<T>(String key) => _box.read<T>(key);
  void removeData(String key) => _box.remove(key);
}
