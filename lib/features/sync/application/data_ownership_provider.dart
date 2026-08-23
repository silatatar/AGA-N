import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/data_ownership.dart';

final dataOwnershipStoreProvider = Provider<DataOwnershipStore>(
  (ref) => SharedPreferencesDataOwnershipStore(),
);
