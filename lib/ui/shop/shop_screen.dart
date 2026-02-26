import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/shop_item.dart';
import '../../data/services/shop_storage_service.dart';
import '../providers/points_provider.dart';
import '../providers/shop_provider.dart';
import 'shop_item_visual.dart';
import 'purchase_history_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/item_localization.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  Future<void> _buyItem(BuildContext context, WidgetRef ref, ShopItem item, int currentPoints) async {
    if (currentPoints >= item.price) {
      // 1. Save points
      await ShopStorageService().savePoints(currentPoints - item.price);
      // 2. Update points provider
      ref.read(pointsProvider.notifier).refreshPoints();
      // 3. Update item purchased status in provider
      await ref.read(shopItemsProvider.notifier).purchaseItem(item);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.purchasedItem(getLocalizedItemName(context, item.id)))),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.notEnoughPoints)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(pointsProvider);
    final items = ref.watch(shopItemsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.shopTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PurchaseHistoryScreen()),
              ).then((_) {
                ref.read(shopItemsProvider.notifier).refreshItems();
                ref.read(pointsProvider.notifier).refreshPoints();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(28.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.water_drop, color: Colors.blueAccent, size: 16),
                  const SizedBox(width: 4),
                  Text('$points', style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: colorScheme.primary.withOpacity(0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.earnPointRule,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty 
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(20.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Opacity(
                                      opacity: item.isPurchased ? 1.0 : 0.4,
                                      child: ShopItemVisual(
                                        itemId: item.id,
                                        size: 100,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            getLocalizedItemName(context, item.id),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Opacity(
                            opacity: item.isPurchased ? 0.3 : 1.0,
                            child: Text(
                              '${item.price} 💧',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: item.isEquipped 
                                    ? Colors.redAccent 
                                    : item.isPurchased 
                                        ? colorScheme.primary 
                                        : Colors.blueAccent,
                                minimumSize: const Size(double.infinity, 36),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                              ),
                              onPressed: () {
                                if (!item.isPurchased) {
                                  _buyItem(context, ref, item, points);
                                } else {
                                  ref.read(shopItemsProvider.notifier).toggleEquip(item);
                                }
                              },
                              child: Text(
                                item.isEquipped 
                                    ? AppLocalizations.of(context)!.unequipBtn
                                    : item.isPurchased 
                                        ? AppLocalizations.of(context)!.equipBtn
                                        : AppLocalizations.of(context)!.buyBtn,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
