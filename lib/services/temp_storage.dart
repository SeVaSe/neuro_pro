class TempStorage {
  // Хранилище данных в формате ключ-значение
  final Map<String, dynamic> _storage = {};
  String? _videoPath;

  // Метод для сохранения данных с уникальным ключом (например, "screen_name.key")
  void saveData(String key, dynamic value) {
    _storage[key] = value;
  }

  // Метод для получения данных по ключу
  dynamic getData(String key) {
    return _storage[key];
  }

  // Метод для удаления данных по ключу
  void removeData(String key) {
    _storage.remove(key);
  }

  // Метод для очистки всех данных
  void clearAllData() {
    _storage.clear();
    _videoPath = null;
  }

  // Очистка данных для конкретного экрана (например, "screen_name.*")
  void clearScreenData(String screenName) {
    _storage.removeWhere((key, value) => key.startsWith(screenName));
  }

  // Получение всех данных для статистики
  Map<String, dynamic> getAllData() {
    return Map.unmodifiable(_storage);
  }

  void storeVideoPath(String path) {
    _videoPath = path;
  }

  String? get videoPath => _videoPath;
}
