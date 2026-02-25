import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shop_item.dart';

class ShopStorageService {
  static const String _shopItemsKey = 'shop_items_data';
  static const String _pointsKey = 'water_drop_points';

  // 1. 초기 데이터 리스트 생성
  final List<ShopItem> _initialItems = [
    ShopItem(id: 'hat_red', name: '빨간 캡모자', price: 10, category: 'head'),
    ShopItem(id: 'hat_crown', name: '작은 왕관', price: 30, category: 'head'),
    ShopItem(id: 'hat_straw', name: '밀짚모자', price: 20, category: 'head'),
    ShopItem(id: 'hat_wizard', name: '마법사 모자', price: 40, category: 'head'),
    ShopItem(id: 'hat_party', name: '파티 모자', price: 15, category: 'head'),
    ShopItem(id: 'face_glasses', name: '선글라스', price: 20, category: 'face'),
    ShopItem(id: 'face_mustache', name: '콧수염', price: 25, category: 'face'),
    ShopItem(id: 'face_blush', name: '발그레', price: 15, category: 'face'),
    ShopItem(id: 'face_mask', name: '마스크', price: 10, category: 'face'),
    ShopItem(id: 'bg_forest', name: '숲속 배경', price: 50, category: 'bg'),
    ShopItem(id: 'bg_space', name: '우주 배경', price: 100, category: 'bg'),
    ShopItem(id: 'bg_beach', name: '해변 배경', price: 60, category: 'bg'),
    ShopItem(id: 'bg_city', name: '도시 배경', price: 80, category: 'bg'),
    ShopItem(id: 'bg_snow', name: '눈밭 배경', price: 70, category: 'bg'),
  ];

  /// 2. SharedPreferences에서 아이템 목록 불러오기
  Future<List<ShopItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString(_shopItemsKey);

    if (itemsJson != null && itemsJson.isNotEmpty) {
      try {
        final List<dynamic> decodedList = jsonDecode(itemsJson);
        final List<ShopItem> loadedItems = decodedList.map((json) => ShopItem.fromJson(json)).toList();
        
        // Merge with initial items to gracefully add new items during updates
        List<ShopItem> mergedItems = _getDefaultItems();
        for (var loaded in loadedItems) {
          int index = mergedItems.indexWhere((i) => i.id == loaded.id);
          if (index != -1) {
            mergedItems[index] = loaded;
          }
        }
        return mergedItems;
      } catch (e) {
        // 파싱 오류 시 초기 데이터로 폴백
        return _getDefaultItems();
      }
    } else {
      // 저장된 데이터가 없으면 초기 데이터 반환
      return _getDefaultItems();
    }
  }

  /// 3. SharedPreferences에 아이템 목록 저장하기
  Future<void> saveItems(List<ShopItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_shopItemsKey, itemsJson);
  }

  // 깊은 복사를 통해 초기 아이템의 여러 인스턴스를 보호
  List<ShopItem> _getDefaultItems() {
    return _initialItems.map((item) => item.copyWith()).toList();
  }

  /// [선택 사항] 포인트 저장
  Future<void> savePoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, points);
  }

  /// [선택 사항] 포인트 불러오기
  Future<int> loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey) ?? 0; // 기본값 0 포인트
  }

  /// 100보 단위 포인트 적립 로직
  Future<int> checkAndEarnPoints(int currentSteps) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 날짜별로 누적된 걸음수의 임계값을 추적 (자정이 지나면 steps가 0부터 다시 시작하므로 날짜별 키 사용)
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final thresholdKey = 'points_threshold_$todayStr';
    
    int currentThreshold = prefs.getInt(thresholdKey) ?? 0;
    int newThreshold = currentSteps ~/ 100;
    
    if (newThreshold > currentThreshold) {
      int pointsToEarn = newThreshold - currentThreshold;
      int currentPoints = await loadPoints();
      
      // 포인트 합산 후 저장
      await savePoints(currentPoints + pointsToEarn);
      // 오늘 어디까지 포인트를 줬는지 저장
      await prefs.setInt(thresholdKey, newThreshold);
      
      return pointsToEarn;
    }
    
    return 0; // 추가 포인트 없음
  }
}
