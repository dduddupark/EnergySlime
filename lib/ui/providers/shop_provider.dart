import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/shop_storage_service.dart';
import '../../data/models/shop_item.dart';

final shopItemsProvider = NotifierProvider<ShopItemsNotifier, List<ShopItem>>(ShopItemsNotifier.new);

class ShopItemsNotifier extends Notifier<List<ShopItem>> {
  @override
  List<ShopItem> build() {
    Future.microtask(() => refreshItems());
    return [];
  }

  Future<void> refreshItems() async {
    final items = await ShopStorageService().loadItems();
    state = items;
  }

  Future<void> toggleEquip(ShopItem item) async {
    final items = state.map((i) {
      if (i.id == item.id) {
        return i.copyWith(isEquipped: !i.isEquipped);
      } else if (i.category == item.category) {
        return i.copyWith(isEquipped: false);
      }
      return i;
    }).toList();
    
    state = items;
    await ShopStorageService().saveItems(items);
  }

  Future<void> purchaseItem(ShopItem item) async {
    final items = state.map((i) {
      if (i.id == item.id) {
        return i.copyWith(isPurchased: true);
      }
      return i;
    }).toList();
    
    state = items;
    await ShopStorageService().saveItems(items);
  }
}

final equippedItemsProvider = Provider<List<ShopItem>>((ref) {
  final items = ref.watch(shopItemsProvider);
  return items.where((i) => i.isEquipped).toList();
});
