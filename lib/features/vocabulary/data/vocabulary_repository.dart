import 'dart:convert';

import '../../sync/data/local_key_value_store.dart';
import '../../sync/domain/data_ownership.dart';
import '../domain/vocabulary_entry.dart';

abstract interface class VocabularyRepository {
  Future<List<VocabularyEntry>> readAll();
  Future<void> save(VocabularyEntry entry);
  Future<void> remove(String id);
  Future<void> update(VocabularyEntry entry);
}

class SharedPreferencesVocabularyRepository implements VocabularyRepository {
  SharedPreferencesVocabularyRepository({
    LocalKeyValueStore? store,
    this.ownership,
  }) : _store = store ?? SharedPreferencesLocalKeyValueStore();
  static const storageKey = 'again.vocabulary_entries';
  static const schemaVersion = 2;
  final LocalKeyValueStore _store;
  final DataOwnershipStore? ownership;

  Future<String> _key() async => ownership == null
      ? storageKey
      : (await ownership!.current()).storageKey(storageKey);

  @override
  Future<List<VocabularyEntry>> readAll() async {
    final owner = ownership == null ? null : await ownership!.current();
    final scopedKey = await _key();
    var raw = await _store.getString(scopedKey);
    if (raw == null && owner?.kind == DataOwnerKind.guest) {
      raw = await _store.getString(storageKey);
      if (raw != null) await _store.setString(scopedKey, raw);
    }
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

  Future<void> _write(List<VocabularyEntry> entries) async => _store.setString(
    await _key(),
    jsonEncode({
      'version': schemaVersion,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    }),
  );
}
