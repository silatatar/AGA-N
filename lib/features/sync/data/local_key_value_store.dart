import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalKeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<int?> getInt(String key);
  Future<void> setInt(String key, int value);
  Future<List<String>?> getStringList(String key);
}

class SharedPreferencesLocalKeyValueStore implements LocalKeyValueStore {
  SharedPreferencesLocalKeyValueStore([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();
  final SharedPreferencesAsync _preferences;
  @override
  Future<String?> getString(String key) => _preferences.getString(key);
  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);
  @override
  Future<bool?> getBool(String key) => _preferences.getBool(key);
  @override
  Future<void> setBool(String key, bool value) =>
      _preferences.setBool(key, value);
  @override
  Future<int?> getInt(String key) => _preferences.getInt(key);
  @override
  Future<void> setInt(String key, int value) => _preferences.setInt(key, value);
  @override
  Future<List<String>?> getStringList(String key) =>
      _preferences.getStringList(key);
}

class MemoryLocalKeyValueStore implements LocalKeyValueStore {
  final Map<String, Object> values = {};
  @override
  Future<String?> getString(String key) async => values[key] as String?;
  @override
  Future<void> setString(String key, String value) async => values[key] = value;
  @override
  Future<bool?> getBool(String key) async => values[key] as bool?;
  @override
  Future<void> setBool(String key, bool value) async => values[key] = value;
  @override
  Future<int?> getInt(String key) async => values[key] as int?;
  @override
  Future<void> setInt(String key, int value) async => values[key] = value;
  @override
  Future<List<String>?> getStringList(String key) async =>
      (values[key] as List<String>?)?.toList();
}
