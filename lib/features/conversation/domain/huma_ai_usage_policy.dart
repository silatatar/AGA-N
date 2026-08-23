enum HumaAiUsageOwnerKind { authenticatedUser, guestDevice }

class HumaAiUsageKey {
  const HumaAiUsageKey({required this.kind, required this.ownerKey});
  final HumaAiUsageOwnerKind kind;
  final String ownerKey;
}

class HumaAiUsagePolicy {
  const HumaAiUsagePolicy({
    this.authenticatedRequestsPerMinute = 12,
    this.authenticatedRequestsPerDay = 120,
    this.guestRequestsPerMinute = 3,
    this.guestRequestsPerDay = 12,
    this.maxInputCharacters = 1200,
    this.maxOutputCharacters = 1800,
    this.maxRecentTurns = 8,
    this.maxRetries = 1,
  });

  final int authenticatedRequestsPerMinute;
  final int authenticatedRequestsPerDay;
  final int guestRequestsPerMinute;
  final int guestRequestsPerDay;
  final int maxInputCharacters;
  final int maxOutputCharacters;
  final int maxRecentTurns;
  final int maxRetries;
}

enum HumaAiUsageDecision { allowed, minuteLimitReached, dailyLimitReached }

abstract interface class HumaAiRateLimiter {
  HumaAiUsageDecision checkAndRecord(HumaAiUsageKey key, DateTime now);
}

/// Deterministic local policy implementation for tests and future backend
/// parity. Production enforcement must live on the AGAIN backend.
class InMemoryHumaAiRateLimiter implements HumaAiRateLimiter {
  InMemoryHumaAiRateLimiter({this.policy = const HumaAiUsagePolicy()});
  final HumaAiUsagePolicy policy;
  final Map<String, List<DateTime>> _events = {};

  @override
  HumaAiUsageDecision checkAndRecord(HumaAiUsageKey key, DateTime now) {
    final events = _events.putIfAbsent(
      '${key.kind.name}:${key.ownerKey}',
      () => [],
    );
    events.removeWhere(
      (event) => now.difference(event) >= const Duration(days: 1),
    );
    final minuteLimit = key.kind == HumaAiUsageOwnerKind.authenticatedUser
        ? policy.authenticatedRequestsPerMinute
        : policy.guestRequestsPerMinute;
    final dailyLimit = key.kind == HumaAiUsageOwnerKind.authenticatedUser
        ? policy.authenticatedRequestsPerDay
        : policy.guestRequestsPerDay;
    if (events.length >= dailyLimit) {
      return HumaAiUsageDecision.dailyLimitReached;
    }
    final recent = events
        .where((event) => now.difference(event) < const Duration(minutes: 1))
        .length;
    if (recent >= minuteLimit) {
      return HumaAiUsageDecision.minuteLimitReached;
    }
    events.add(now);
    return HumaAiUsageDecision.allowed;
  }
}
