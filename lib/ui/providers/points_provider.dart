import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/shop_storage_service.dart';

final pointsProvider = NotifierProvider<PointsNotifier, int>(PointsNotifier.new);

class PointsNotifier extends Notifier<int> {
  @override
  int build() {
    // Cannot make build async if we define state as just 'int' (Notifier vs AsyncNotifier).
    // So we fetch it asynchronously and update state later, returning initial 0 immediately.
    Future.microtask(() => refreshPoints());
    return 0; // initial state
  }

  Future<void> refreshPoints() async {
    final pts = await ShopStorageService().loadPoints();
    state = pts;
  }
}
