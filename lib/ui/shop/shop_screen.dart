import 'package:flutter/material.dart';
import '../../data/models/shop_item.dart';
import '../../data/services/shop_storage_service.dart';
import 'shop_item_visual.dart';

class ShopScreen extends StatefulWidget {
  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ShopStorageService _storageService = ShopStorageService();
  List<ShopItem> _items = [];
  int _points = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    final items = await _storageService.loadItems();
    final points = await _storageService.loadPoints();
    setState(() {
      _items = items;
      _points = points;
      _isLoading = false;
    });
  }

  Future<void> _buyItem(ShopItem item) async {
    if (_points >= item.price) {
      setState(() {
        _points -= item.price;
        item.isPurchased = true;
      });
      await _storageService.savePoints(_points);
      await _storageService.saveItems(_items);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name}을(를) 구매했습니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('포인트가 부족합니다! 걷기를 통해 물방울을 모아보세요.')),
      );
    }
  }

  Future<void> _equipItem(ShopItem item) async {
    setState(() {
      // 같은 카테고리의 기존 장착 해제
      for (var obj in _items) {
        if (obj.category == item.category) {
          obj.isEquipped = false;
        }
      }
      // 새 아이템 장착
      item.isEquipped = true;
    });
    await _storageService.saveItems(_items);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('상점', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.blueAccent, size: 16),
                const SizedBox(width: 4),
                Text('$_points', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75, // 세로로 약간 길게
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Opacity(
                        opacity: item.isPurchased ? 1.0 : 0.4,
                        child: ShopItemVisual(
                          itemId: item.id,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                if (!item.isPurchased)
                  Text(
                    '${item.price} 💧',
                    style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold),
                  )
                else
                  const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.isEquipped 
                          ? Colors.grey 
                          : item.isPurchased 
                              ? colorScheme.primary 
                              : Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (!item.isPurchased) {
                        _buyItem(item);
                      } else if (!item.isEquipped) {
                        _equipItem(item);
                      }
                    },
                    child: Text(
                      item.isEquipped 
                          ? '착용 중' 
                          : item.isPurchased 
                              ? '착용하기' 
                              : '구매',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
