import 'package:flutter/foundation.dart';
import 'package:neuro_pro/services/temp_storage.dart';

class DiagnosticLogger {
  /// Логирует текущее значение диагностического параметра из хранилища.
  ///
  /// [diagnosticName] — название диагностики (например, "Диагностический тип"),
  /// [storageKey] — ключ для получения данных из хранилища,
  /// [storage] — экземпляр TempStorage, из которого извлекаются данные.
  static void logDiagnostic(String diagnosticName, String storageKey, TempStorage storage) {
    final diagnosticValue = storage.getData(storageKey);
    final logMessage = '''
========================================
Диагностика: $diagnosticName
Ключ хранилища: $storageKey
Сохраненное значение: $diagnosticValue
========================================
    ''';
    debugPrint(logMessage);
  }
}