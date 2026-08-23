import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

enum DataOwnerKind { guest, user }

class DataOwner {
  const DataOwner.guest(this.id) : kind = DataOwnerKind.guest;
  const DataOwner.user(this.id) : kind = DataOwnerKind.user;

  final DataOwnerKind kind;
  final String id;

  String get namespace => '${kind.name}:$id';
  String storageKey(String logicalKey) => 'again.$namespace.$logicalKey';
}

abstract interface class DataOwnershipStore {
  Future<DataOwner> current();
  Future<DataOwner> guest();
  Future<void> switchTo(DataOwner owner);
  Future<bool> wasGuestAdoptedBy(String userId);
  Future<void> markGuestAdoptedBy(String userId);
}

class SharedPreferencesDataOwnershipStore implements DataOwnershipStore {
  SharedPreferencesDataOwnershipStore({
    this.installationId,
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _ownerKey = 'again.data_owner.v1';
  static const _installationKey = 'again.installation_id.v1';
  static const _adoptionPrefix = 'again.guest_adoption.v1.';
  final String? installationId;
  final SharedPreferencesAsync _preferences;

  @override
  Future<DataOwner> current() async {
    final stored = await _preferences.getString(_ownerKey);
    if (stored?.startsWith('user:') == true) {
      return DataOwner.user(stored!.substring(5));
    }
    if (stored?.startsWith('guest:') == true) {
      return DataOwner.guest(stored!.substring(6));
    }
    return guest();
  }

  @override
  Future<DataOwner> guest() async {
    final existing =
        installationId ?? await _preferences.getString(_installationKey);
    if (existing != null && existing.isNotEmpty) {
      return DataOwner.guest(existing);
    }
    final generated =
        '${DateTime.now().toUtc().microsecondsSinceEpoch.toRadixString(36)}-${Random.secure().nextInt(4294967296).toRadixString(36)}';
    await _preferences.setString(_installationKey, generated);
    return DataOwner.guest(generated);
  }

  @override
  Future<void> switchTo(DataOwner owner) =>
      _preferences.setString(_ownerKey, owner.namespace);

  @override
  Future<bool> wasGuestAdoptedBy(String userId) async =>
      await _preferences.getBool('$_adoptionPrefix$userId') ?? false;

  @override
  Future<void> markGuestAdoptedBy(String userId) =>
      _preferences.setBool('$_adoptionPrefix$userId', true);
}

class MemoryDataOwnershipStore implements DataOwnershipStore {
  MemoryDataOwnershipStore(this.owner)
    : _guestOwner = owner.kind == DataOwnerKind.guest
          ? owner
          : const DataOwner.guest('stable-guest');
  DataOwner owner;
  final DataOwner _guestOwner;
  final Set<String> adoptedUsers = {};

  @override
  Future<DataOwner> current() async => owner;
  @override
  Future<DataOwner> guest() async => _guestOwner;
  @override
  Future<void> switchTo(DataOwner value) async => owner = value;
  @override
  Future<bool> wasGuestAdoptedBy(String userId) async =>
      adoptedUsers.contains(userId);
  @override
  Future<void> markGuestAdoptedBy(String userId) async =>
      adoptedUsers.add(userId);
}
