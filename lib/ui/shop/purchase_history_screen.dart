import 'package:flutter/material.dart';
import '../../data/models/shop_item.dart';
import '../../data/services/shop_storage_service.dart';
import 'shop_item_visual.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  @override
  _PurchaseHistoryScreenState createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final ShopStorageService _storageService = ShopStorageService();
  List<ShopItem> _purchasedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await _storageService.loadItems();
    if (mounted) {
      setState(() {
        _purchasedItems = items.where((item) => item.isPurchased).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('구매 내역', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _purchasedItems.isEmpty
              ? const Center(
                  child: Text(
                    '아직 구매한 아이템이 없습니다.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _purchasedItems.length,
                  itemBuilder: (context, index) {
                    final item = _purchasedItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: ShopItemVisual(itemId: item.id, size: 40),
                            ),
                          ),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          item.category == 'bg'
                              ? '배경'
                              : item.category == 'face'
                                  ? '얼굴 꾸미기'
                                  : '모자',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        trailing: item.isEquipped
                            ? const Text('착용 중', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
                            : const Text('보관 중', style: TextStyle(color: Colors.blueAccent)),
                      ),
                    );
                  },
                ),
    );
  }
}
