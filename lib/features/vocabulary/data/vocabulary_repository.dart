import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/vocabulary_entry.dart';

abstract interface class VocabularyRepository {
  Future<List<VocabularyEntry>> readAll();
  Future<void> save(VocabularyEntry entry);
  Future<void> remove(String id);
  Future<void> update(VocabularyEntry entry);
}

class SharedPreferencesVocabularyRepository implements VocabularyRepository {
  SharedPreferencesVocabularyRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();
  static const _key = 'again.vocabulary_entries';
  static const schemaVersion = 2;
  final SharedPreferencesAsync _preferences;

  @override
  Future<List<VocabularyEntry>> readAll() async {
    final raw = await _preferences.getString(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    final list = decoded is List<dynamic>
        ? decoded
        : (decoded as Map<String, dynamic>)['entries'] as List<dynamic>;
    return list
        .map((item) => VocabularyEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(VocabularyEntry entry) async {
    final entries = await readAll();
    if (entries.any((item) => item.id == entry.id)) return;
    await _write([...entries, entry]);
  }

  @override
  Future<void> remove(String id) async {
    final entries = await readAll()
      ..removeWhere((entry) => entry.id == id);
    await _write(entries);
  }

  @override
  Future<void> update(VocabularyEntry entry) async {
    final entries = await readAll();
    final index = entries.indexWhere((item) => item.id == entry.id);
    if (index < 0) return;
    entries[index] = entry;
    await _write(entries);
  }

  Future<void> _write(List<VocabularyEntry> entries) => _preferences.setString(
    _key,
    jsonEncode({
      'version': schemaVersion,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    }),
  );
}
