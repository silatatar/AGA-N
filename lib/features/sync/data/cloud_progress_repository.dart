import '../domain/sync_models.dart';

abstract interface class CloudProgressRepository {
  bool get isConfigured;
  Future<CloudProgressDocument?> fetch(String userId);
  Future<void> push(CloudProgressDocument document);
  Future<void> deleteForUser(String userId);
}

class CloudRepositoryException implements Exception {
  const CloudRepositoryException(this.kind);
  final SyncFailureKind kind;
}

/// Test-only implementation. Production runtime must never present this as a
/// real cloud service.
class InMemoryCloudProgressRepository implements CloudProgressRepository {
  final Map<String, CloudProgressDocument> documents = {};

  @override
  bool get isConfigured => true;

  @override
  Future<CloudProgressDocument?> fetch(String userId) async =>
      documents[userId];

  @override
  Future<void> push(CloudProgressDocument document) async {
    documents[document.userId] = document;
  }

  @override
  Future<void> deleteForUser(String userId) async {
    documents.remove(userId);
  }
}

class UnconfiguredCloudProgressRepository implements CloudProgressRepository {
  const UnconfiguredCloudProgressRepository();

  @override
  bool get isConfigured => false;

  @override
  Future<CloudProgressDocument?> fetch(String userId) async => null;

  @override
  Future<void> push(CloudProgressDocument document) =>
      throw StateError('Cloud provider is not configured.');

  @override
  Future<void> deleteForUser(String userId) =>
      throw StateError('Cloud provider is not configured.');
}
