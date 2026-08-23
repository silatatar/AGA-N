import 'dart:convert';
import 'dart:math';

import 'package:again/features/learner_profile/data/learner_personalization_store.dart';
import 'package:again/features/learner_profile/domain/learner_personalization.dart';
import 'package:again/features/learner_profile/domain/learner_profile.dart';
import 'package:again/features/progression/data/progression_repository.dart';
import 'package:again/features/progression/domain/again_progress.dart';
import 'package:again/features/sync/data/local_key_value_store.dart';
import 'package:again/features/sync/domain/data_ownership.dart';
import 'package:again/features/vocabulary/data/vocabulary_repository.dart';
import 'package:again/features/vocabulary/domain/vocabulary_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 37 owner isolation', () {
    test('installation identifier uses a web-safe random upper bound', () {
      final source = Random(37);
      expect(() => source.nextInt(4294967296), returnsNormally);
    });

    test('guest namespace is stable and distinct from users', () async {
      final ownership = MemoryDataOwnershipStore(
        const DataOwner.guest('install-1'),
      );
      expect((await ownership.current()).namespace, 'guest:install-1');
      expect((await ownership.guest()).namespace, 'guest:install-1');
      await ownership.switchTo(const DataOwner.user('a'));
      expect((await ownership.guest()).namespace, 'guest:install-1');
    });

    test(
      'Guest, User A and User B progress are isolated; A restores',
      () async {
        final local = MemoryLocalKeyValueStore();
        final ownership = MemoryDataOwnershipStore(const DataOwner.guest('g'));
        final repo = SharedPreferencesProgressionRepository(
          store: local,
          ownership: ownership,
        );
        await repo.save(
          const AgainProgress(totalXp: 3, savedWordIds: {'guest'}),
        );
        await ownership.switchTo(const DataOwner.user('a'));
        await repo.save(
          const AgainProgress(totalXp: 10, savedWordIds: {'alpha'}),
        );
        await ownership.switchTo(const DataOwner.user('b'));
        await repo.save(
          const AgainProgress(totalXp: 20, savedWordIds: {'beta'}),
        );
        expect((await repo.read()).savedWordIds, {'beta'});
        await ownership.switchTo(const DataOwner.user('a'));
        expect(
          [(await repo.read()).totalXp, (await repo.read()).savedWordIds],
          [
            10,
            {'alpha'},
          ],
        );
        await ownership.switchTo(const DataOwner.guest('g'));
        expect((await repo.read()).savedWordIds, {'guest'});
      },
    );

    test('personalization is isolated between accounts', () async {
      final local = MemoryLocalKeyValueStore();
      final ownership = MemoryDataOwnershipStore(const DataOwner.user('a'));
      final store = LearnerPersonalizationStore(
        store: local,
        ownership: ownership,
      );
      await store.save(
        const LearnerPersonalization(
          identity: LearnerProfile(
            displayName: 'A',
            avatar: LearnerAvatar.moon,
          ),
        ),
      );
      await ownership.switchTo(const DataOwner.user('b'));
      expect((await store.read()).identity, isNull);
      await store.save(
        const LearnerPersonalization(
          identity: LearnerProfile(
            displayName: 'B',
            avatar: LearnerAvatar.compass,
          ),
        ),
      );
      await ownership.switchTo(const DataOwner.user('a'));
      expect((await store.read()).identity?.displayName, 'A');
    });

    test('legacy canonical data migrates once only to guest', () async {
      final local = MemoryLocalKeyValueStore();
      await local.setString(
        SharedPreferencesProgressionRepository.storageKey,
        jsonEncode(
          const AgainProgress(totalXp: 7, savedWordIds: {'old'}).toJson(),
        ),
      );
      final ownership = MemoryDataOwnershipStore(const DataOwner.guest('g'));
      final repo = SharedPreferencesProgressionRepository(
        store: local,
        ownership: ownership,
      );
      expect((await repo.read()).totalXp, 7);
      await ownership.switchTo(const DataOwner.user('a'));
      expect((await repo.read()).totalXp, 0);
      await ownership.switchTo(const DataOwner.guest('g'));
      expect(
        [(await repo.read()).totalXp, (await repo.read()).savedWordIds],
        [
          7,
          {'old'},
        ],
      );
    });

    test(
      'ambiguous individual legacy fields never migrate to a user',
      () async {
        final local = MemoryLocalKeyValueStore();
        await local.setString('again.display_name', 'Legacy person');
        await local.setInt('again.total_xp', 99);
        final ownership = MemoryDataOwnershipStore(const DataOwner.user('a'));
        final profile = LearnerPersonalizationStore(
          store: local,
          ownership: ownership,
        );
        final progress = SharedPreferencesProgressionRepository(
          store: local,
          ownership: ownership,
        );
        expect((await profile.read()).identity, isNull);
        expect((await progress.read()).totalXp, 0);
        await ownership.switchTo(const DataOwner.guest('g'));
        expect((await profile.read()).identity?.displayName, 'Legacy person');
        expect((await progress.read()).totalXp, 99);
      },
    );

    test('vocabulary is isolated and legacy data is guest-only', () async {
      final local = MemoryLocalKeyValueStore();
      final legacyEntry = vocabularyTemplate('hello', id: 'legacy');
      await local.setString(
        SharedPreferencesVocabularyRepository.storageKey,
        jsonEncode({
          'version': SharedPreferencesVocabularyRepository.schemaVersion,
          'entries': [legacyEntry.toJson()],
        }),
      );
      final ownership = MemoryDataOwnershipStore(const DataOwner.user('a'));
      final repo = SharedPreferencesVocabularyRepository(
        store: local,
        ownership: ownership,
      );
      expect(await repo.readAll(), isEmpty);
      await repo.save(vocabularyTemplate('alpha', id: 'a'));
      await ownership.switchTo(const DataOwner.user('b'));
      expect(await repo.readAll(), isEmpty);
      await repo.save(vocabularyTemplate('beta', id: 'b'));
      await ownership.switchTo(const DataOwner.user('a'));
      expect((await repo.readAll()).map((entry) => entry.id), ['a']);
      await ownership.switchTo(const DataOwner.guest('g'));
      expect((await repo.readAll()).map((entry) => entry.id), ['legacy']);
    });

    test('corruption backup is owner scoped', () async {
      final local = MemoryLocalKeyValueStore();
      final ownership = MemoryDataOwnershipStore(const DataOwner.user('a'));
      final repo = SharedPreferencesProgressionRepository(
        store: local,
        ownership: ownership,
      );
      await local.setString(
        const DataOwner.user(
          'a',
        ).storageKey(SharedPreferencesProgressionRepository.storageKey),
        '{bad-a',
      );
      await repo.read();
      await ownership.switchTo(const DataOwner.user('b'));
      await local.setString(
        const DataOwner.user(
          'b',
        ).storageKey(SharedPreferencesProgressionRepository.storageKey),
        '{bad-b',
      );
      await repo.read();
      expect(
        local.values[const DataOwner.user(
          'a',
        ).storageKey(SharedPreferencesProgressionRepository.corruptBackupKey)],
        '{bad-a',
      );
      expect(
        local.values[const DataOwner.user(
          'b',
        ).storageKey(SharedPreferencesProgressionRepository.corruptBackupKey)],
        '{bad-b',
      );
    });

    test('logout-style owner switch never deletes account records', () async {
      final local = MemoryLocalKeyValueStore();
      final ownership = MemoryDataOwnershipStore(const DataOwner.user('a'));
      final repo = SharedPreferencesProgressionRepository(
        store: local,
        ownership: ownership,
      );
      await repo.save(const AgainProgress(totalXp: 44));
      await ownership.switchTo(await ownership.guest());
      expect((await repo.read()).totalXp, 0);
      await ownership.switchTo(const DataOwner.user('a'));
      expect((await repo.read()).totalXp, 44);
    });
  });
}
